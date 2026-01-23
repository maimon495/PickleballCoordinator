import Foundation
import SwiftData

@Model
final class Game {
    var id: UUID
    var title: String
    var notes: String
    var status: GameStatus
    var gameType: GameType
    var minimumPlayers: Int
    var createdAt: Date

    // Confirmed details
    var confirmedDate: Date?
    var addedToCalendar: Bool

    // Location
    @Relationship(deleteRule: .nullify)
    var court: Court?

    // Participants
    @Relationship(deleteRule: .nullify)
    var players: [Player]?

    // Time options for scheduling
    @Relationship(deleteRule: .cascade, inverse: \GameTimeOption.game)
    var timeOptions: [GameTimeOption]?

    // Results (for completed games)
    @Relationship(deleteRule: .cascade, inverse: \GameResult.game)
    var results: [GameResult]?

    // Social features
    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.game)
    var messages: [ChatMessage]?

    @Relationship(deleteRule: .cascade, inverse: \GamePhoto.game)
    var photos: [GamePhoto]?

    init(
        title: String = "",
        gameType: GameType = .doubles,
        minimumPlayers: Int = 4,
        notes: String = ""
    ) {
        self.id = UUID()
        self.title = title.isEmpty ? "Pickleball Game" : title
        self.notes = notes
        self.status = .scheduling
        self.gameType = gameType
        self.minimumPlayers = minimumPlayers
        self.createdAt = Date()
        self.addedToCalendar = false
    }

    var displayTitle: String {
        if !title.isEmpty && title != "Pickleball Game" {
            return title
        }
        if let court = court {
            return "Game at \(court.name)"
        }
        return "Pickleball Game"
    }

    var confirmedPlayerCount: Int {
        guard let options = timeOptions, let confirmedOption = options.first(where: { $0.isConfirmed }) else {
            return 0
        }
        return confirmedOption.confirmedPlayers?.count ?? 0
    }

    var hasEnoughPlayers: Bool {
        confirmedPlayerCount >= minimumPlayers
    }

    var formattedDate: String {
        guard let date = confirmedDate else { return "TBD" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum GameStatus: String, Codable {
    case scheduling
    case confirmed
    case inProgress
    case completed
    case cancelled

    var displayName: String {
        switch self {
        case .scheduling: return "Scheduling"
        case .confirmed: return "Confirmed"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    var iconName: String {
        switch self {
        case .scheduling: return "calendar.badge.clock"
        case .confirmed: return "checkmark.circle.fill"
        case .inProgress: return "play.circle.fill"
        case .completed: return "flag.checkered"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}

enum GameType: String, Codable, CaseIterable {
    case singles
    case doubles
    case mixedDoubles

    var displayName: String {
        switch self {
        case .singles: return "Singles"
        case .doubles: return "Doubles"
        case .mixedDoubles: return "Mixed Doubles"
        }
    }

    var playerCount: Int {
        switch self {
        case .singles: return 2
        case .doubles, .mixedDoubles: return 4
        }
    }
}
