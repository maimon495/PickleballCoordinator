import Foundation
import SwiftData

@Model
final class GameResult {
    var id: UUID
    var matchNumber: Int // For multiple matches in one session
    var team1Score: Int
    var team2Score: Int
    var completedAt: Date

    @Relationship(deleteRule: .nullify)
    var game: Game?

    // Team compositions stored as player IDs
    var team1PlayerIDs: [String]
    var team2PlayerIDs: [String]

    init(
        matchNumber: Int = 1,
        team1Score: Int = 0,
        team2Score: Int = 0,
        team1PlayerIDs: [String] = [],
        team2PlayerIDs: [String] = []
    ) {
        self.id = UUID()
        self.matchNumber = matchNumber
        self.team1Score = team1Score
        self.team2Score = team2Score
        self.completedAt = Date()
        self.team1PlayerIDs = team1PlayerIDs
        self.team2PlayerIDs = team2PlayerIDs
    }

    var winningTeam: Int? {
        if team1Score > team2Score { return 1 }
        if team2Score > team1Score { return 2 }
        return nil
    }

    var scoreDisplay: String {
        "\(team1Score) - \(team2Score)"
    }

    func didPlayerWin(_ player: Player) -> Bool {
        let playerID = player.id.uuidString
        if team1PlayerIDs.contains(playerID) {
            return winningTeam == 1
        }
        if team2PlayerIDs.contains(playerID) {
            return winningTeam == 2
        }
        return false
    }

    func wasPlayerOnTeam(_ player: Player, team: Int) -> Bool {
        let playerID = player.id.uuidString
        switch team {
        case 1: return team1PlayerIDs.contains(playerID)
        case 2: return team2PlayerIDs.contains(playerID)
        default: return false
        }
    }
}

// MARK: - Head to Head Record

struct HeadToHeadRecord {
    let player1: Player
    let player2: Player
    var gamesAsTeammates: Int = 0
    var winsAsTeammates: Int = 0
    var gamesAsOpponents: Int = 0
    var winsAgainst: Int = 0 // Player 1's wins against player 2

    var teammateWinRate: Double {
        guard gamesAsTeammates > 0 else { return 0 }
        return Double(winsAsTeammates) / Double(gamesAsTeammates)
    }

    var opponentWinRate: Double {
        guard gamesAsOpponents > 0 else { return 0 }
        return Double(winsAgainst) / Double(gamesAsOpponents)
    }
}
