import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    // MARK: - Permission

    func requestAuthorization() async -> Bool {
        do {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            }
            return settings.authorizationStatus == .authorized
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Game Reminders

    func scheduleGameReminder(for game: Game, minutesBefore: Int = 60) async {
        guard let confirmedDate = game.confirmedDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Game"
        content.body = "Your pickleball game \"\(game.displayTitle)\" starts in \(minutesBefore) minutes"
        content.sound = .default
        content.categoryIdentifier = "GAME_REMINDER"

        let triggerDate = confirmedDate.addingTimeInterval(-Double(minutesBefore * 60))
        guard triggerDate > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "game-reminder-\(game.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule game reminder: \(error)")
        }
    }

    func cancelGameReminder(for game: Game) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["game-reminder-\(game.id.uuidString)"]
        )
    }

    // MARK: - Invite Notifications

    func scheduleInviteNotification(for game: Game, playerName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "New Game Invite"
        content.body = "\(playerName) invited you to play pickleball"
        content.sound = .default
        content.categoryIdentifier = "GAME_INVITE"

        let request = UNNotificationRequest(
            identifier: "game-invite-\(game.id.uuidString)",
            content: content,
            trigger: nil // Immediate
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send invite notification: \(error)")
        }
    }

    // MARK: - RSVP Notifications

    func scheduleRSVPNotification(for game: Game, playerName: String, response: RSVPStatus) async {
        let content = UNMutableNotificationContent()
        content.title = "RSVP Update"

        switch response {
        case .yes:
            content.body = "\(playerName) is coming to \(game.displayTitle)"
        case .no:
            content.body = "\(playerName) can't make it to \(game.displayTitle)"
        case .maybe:
            content.body = "\(playerName) might come to \(game.displayTitle)"
        case .pending:
            return
        }

        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "rsvp-\(game.id.uuidString)-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send RSVP notification: \(error)")
        }
    }

    // MARK: - Game Confirmed Notification

    func scheduleGameConfirmedNotification(for game: Game) async {
        guard let confirmedDate = game.confirmedDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Game Confirmed!"
        content.body = "\(game.displayTitle) is confirmed for \(confirmedDate.formatted(date: .abbreviated, time: .shortened))"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "game-confirmed-\(game.id.uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send confirmation notification: \(error)")
        }
    }

    // MARK: - Helper Methods

    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func setupNotificationCategories() {
        // Game Reminder category with actions
        let viewAction = UNNotificationAction(
            identifier: "VIEW_GAME",
            title: "View Game",
            options: .foreground
        )

        let reminderCategory = UNNotificationCategory(
            identifier: "GAME_REMINDER",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )

        // Game Invite category with actions
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_INVITE",
            title: "I'm In!",
            options: .foreground
        )

        let declineAction = UNNotificationAction(
            identifier: "DECLINE_INVITE",
            title: "Can't Make It",
            options: .destructive
        )

        let inviteCategory = UNNotificationCategory(
            identifier: "GAME_INVITE",
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory, inviteCategory])
    }
}
