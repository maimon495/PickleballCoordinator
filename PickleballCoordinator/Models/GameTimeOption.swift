import Foundation
import SwiftData

@Model
final class GameTimeOption {
    var id: UUID
    var proposedDate: Date
    var isConfirmed: Bool

    @Relationship(deleteRule: .nullify)
    var game: Game?

    // RSVPs stored as player IDs with their response
    var rsvpData: [String: String] // Player ID -> RSVPStatus raw value

    // Confirmed players (subset of RSVPs with "yes" response)
    @Relationship(deleteRule: .nullify)
    var confirmedPlayers: [Player]?

    init(proposedDate: Date) {
        self.id = UUID()
        self.proposedDate = proposedDate
        self.isConfirmed = false
        self.rsvpData = [:]
    }

    func rsvpStatus(for player: Player) -> RSVPStatus {
        guard let statusString = rsvpData[player.id.uuidString] else {
            return .pending
        }
        return RSVPStatus(rawValue: statusString) ?? .pending
    }

    func setRSVP(_ status: RSVPStatus, for player: Player) {
        rsvpData[player.id.uuidString] = status.rawValue
    }

    var yesCount: Int {
        rsvpData.values.filter { $0 == RSVPStatus.yes.rawValue }.count
    }

    var noCount: Int {
        rsvpData.values.filter { $0 == RSVPStatus.no.rawValue }.count
    }

    var maybeCount: Int {
        rsvpData.values.filter { $0 == RSVPStatus.maybe.rawValue }.count
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: proposedDate)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: proposedDate)
    }

    var formattedDateTime: String {
        "\(formattedDate) at \(formattedTime)"
    }
}

enum RSVPStatus: String, Codable, CaseIterable {
    case pending
    case yes
    case no
    case maybe

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .yes: return "Yes"
        case .no: return "No"
        case .maybe: return "Maybe"
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "questionmark.circle"
        case .yes: return "checkmark.circle.fill"
        case .no: return "xmark.circle.fill"
        case .maybe: return "minus.circle.fill"
        }
    }
}
