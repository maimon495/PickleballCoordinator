import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID
    var name: String
    var phoneNumber: String
    var skillLevel: SkillLevel
    var isFavorite: Bool
    var notes: String
    var createdAt: Date
    var avatarColor: AvatarColor

    // Availability preferences
    var preferredDays: [Int] // 1 = Sunday, 7 = Saturday
    var preferredTimeStart: Date? // Time component only
    var preferredTimeEnd: Date?

    // Stats tracking
    var gamesPlayed: Int
    var gamesWon: Int
    var currentStreak: Int
    var longestStreak: Int

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \Game.players)
    var games: [Game]?

    init(
        name: String,
        phoneNumber: String = "",
        skillLevel: SkillLevel = .intermediate,
        isFavorite: Bool = false,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.phoneNumber = phoneNumber
        self.skillLevel = skillLevel
        self.isFavorite = isFavorite
        self.notes = notes
        self.createdAt = Date()
        self.avatarColor = AvatarColor.allCases.randomElement() ?? .teal
        self.preferredDays = []
        self.gamesPlayed = 0
        self.gamesWon = 0
        self.currentStreak = 0
        self.longestStreak = 0
    }

    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed)
    }

    var winRatePercentage: String {
        String(format: "%.0f%%", winRate * 100)
    }
}

enum SkillLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    var rating: String {
        switch self {
        case .beginner: return "2.0-2.5"
        case .intermediate: return "3.0-3.5"
        case .advanced: return "4.0+"
        }
    }

    var sortOrder: Int {
        switch self {
        case .beginner: return 0
        case .intermediate: return 1
        case .advanced: return 2
        }
    }
}

enum AvatarColor: String, Codable, CaseIterable {
    case teal
    case coral
    case gold
    case sage
    case plum
    case slate

    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .teal: return (0.20, 0.50, 0.48)
        case .coral: return (0.85, 0.55, 0.48)
        case .gold: return (0.78, 0.65, 0.38)
        case .sage: return (0.55, 0.65, 0.50)
        case .plum: return (0.55, 0.40, 0.55)
        case .slate: return (0.45, 0.50, 0.55)
        }
    }
}
