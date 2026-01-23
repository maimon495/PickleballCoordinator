import Foundation
import UIKit

class ShareService {
    static let shared = ShareService()

    private init() {}

    // MARK: - Generate Share Link

    func generateShareLink(for game: Game) -> URL? {
        // In a real app, this would generate a deep link or web URL
        // For now, we'll create a custom URL scheme
        var components = URLComponents()
        components.scheme = "pickleballcoordinator"
        components.host = "game"
        components.path = "/\(game.id.uuidString)"

        return components.url
    }

    // MARK: - Generate Share Text

    func generateShareText(for game: Game) -> String {
        var text = "Join me for pickleball!"
        text += "\n\n\(game.displayTitle)"

        if let court = game.court {
            text += "\nLocation: \(court.name)"
            if !court.address.isEmpty {
                text += " - \(court.address)"
            }
        }

        if let options = game.timeOptions, !options.isEmpty {
            text += "\n\nProposed times:"
            for option in options.sorted(by: { $0.proposedDate < $1.proposedDate }) {
                text += "\n• \(option.formattedDateTime)"
            }
        } else if let confirmedDate = game.confirmedDate {
            text += "\n\nWhen: \(confirmedDate.formatted(date: .complete, time: .shortened))"
        }

        text += "\n\nRSVP in the Pickleball Coordinator app!"

        return text
    }

    // MARK: - SMS Invite

    func generateSMSBody(for game: Game, playerName: String = "someone") -> String {
        var body = "Hey! \(playerName) invited you to play pickleball."
        body += "\n\n\(game.displayTitle)"

        if let court = game.court {
            body += "\nAt: \(court.name)"
        }

        if let options = game.timeOptions, !options.isEmpty {
            body += "\n\nPossible times:"
            for option in options.prefix(3).sorted(by: { $0.proposedDate < $1.proposedDate }) {
                body += "\n• \(option.formattedDateTime)"
            }
        }

        body += "\n\nReply YES to join!"

        return body
    }

    // MARK: - Share Activity

    func shareGame(_ game: Game, from viewController: UIViewController? = nil) {
        let text = generateShareText(for: game)
        var items: [Any] = [text]

        if let url = generateShareLink(for: game) {
            items.append(url)
        }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        // Exclude some activities that don't make sense
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .print
        ]

        // Get the presenting view controller
        let presenter = viewController ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first

        // For iPad, set the source view
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter?.view
            popover.sourceRect = CGRect(
                x: UIScreen.main.bounds.midX,
                y: UIScreen.main.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter?.present(activityVC, animated: true)
    }

    // MARK: - Open SMS

    func openSMS(to phoneNumber: String, body: String) {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "sms:\(cleanNumber)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Mass Invite

    func sendMassInvite(for game: Game, to players: [Player]) {
        for player in players where !player.phoneNumber.isEmpty {
            let body = generateSMSBody(for: game)
            // In a real app, you'd use a messaging API
            // For now, we'll just open SMS for the first player
            if player == players.first {
                openSMS(to: player.phoneNumber, body: body)
            }
        }
    }
}
