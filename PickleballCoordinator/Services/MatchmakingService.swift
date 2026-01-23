import Foundation

class MatchmakingService {
    static let shared = MatchmakingService()

    private init() {}

    // MARK: - Balanced Team Generation

    /// Generates balanced doubles teams from a list of players
    func generateBalancedTeams(from players: [Player]) -> (team1: [Player], team2: [Player])? {
        guard players.count >= 4 else { return nil }

        let sortedPlayers = players.sorted { $0.skillLevel.sortOrder > $1.skillLevel.sortOrder }
        let selectedPlayers = Array(sortedPlayers.prefix(4))

        // Pair strongest with weakest for balanced teams
        let team1 = [selectedPlayers[0], selectedPlayers[3]]
        let team2 = [selectedPlayers[1], selectedPlayers[2]]

        return (team1, team2)
    }

    /// Generates multiple balanced team configurations
    func generateTeamRotations(from players: [Player], count: Int = 3) -> [[(team1: [Player], team2: [Player])]] {
        guard players.count >= 4 else { return [] }

        var rotations: [[(team1: [Player], team2: [Player])]] = []
        let selectedPlayers = Array(players.prefix(4))

        // All possible pairings
        let pairings: [([Int], [Int])] = [
            ([0, 1], [2, 3]),
            ([0, 2], [1, 3]),
            ([0, 3], [1, 2])
        ]

        for pairing in pairings.prefix(count) {
            let team1 = pairing.0.map { selectedPlayers[$0] }
            let team2 = pairing.1.map { selectedPlayers[$0] }
            rotations.append([(team1: team1, team2: team2)])
        }

        return rotations
    }

    // MARK: - Find Available Players

    /// Finds players available on a given date
    func findAvailablePlayers(for date: Date, from players: [Player]) -> [Player] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date) // 1 = Sunday

        return players.filter { player in
            // Check if player has this day in their preferred days
            if !player.preferredDays.isEmpty {
                return player.preferredDays.contains(weekday)
            }
            // If no preferences set, assume available
            return true
        }
    }

    /// Finds players to fill remaining spots for a game
    func findPlayersToFillGame(
        game: Game,
        allPlayers: [Player],
        excludePlayers: [Player] = []
    ) -> [Player] {
        let currentPlayerIDs = Set(game.players?.map { $0.id } ?? [])
        let excludeIDs = Set(excludePlayers.map { $0.id })

        let candidates = allPlayers.filter { player in
            !currentPlayerIDs.contains(player.id) && !excludeIDs.contains(player.id)
        }

        // Sort by: favorites first, then by skill similarity to existing players
        let currentSkillAverage = calculateAverageSkill(of: game.players ?? [])

        return candidates.sorted { player1, player2 in
            // Favorites always come first
            if player1.isFavorite != player2.isFavorite {
                return player1.isFavorite
            }

            // Then sort by skill similarity
            let diff1 = abs(player1.skillLevel.sortOrder - currentSkillAverage)
            let diff2 = abs(player2.skillLevel.sortOrder - currentSkillAverage)
            return diff1 < diff2
        }
    }

    // MARK: - Skill Analysis

    private func calculateAverageSkill(of players: [Player]) -> Int {
        guard !players.isEmpty else { return 1 }
        let total = players.reduce(0) { $0 + $1.skillLevel.sortOrder }
        return total / players.count
    }

    /// Analyzes how balanced a potential match would be
    func analyzeMatchBalance(team1: [Player], team2: [Player]) -> MatchBalance {
        let team1Skill = team1.reduce(0) { $0 + $1.skillLevel.sortOrder }
        let team2Skill = team2.reduce(0) { $0 + $1.skillLevel.sortOrder }

        let difference = abs(team1Skill - team2Skill)

        switch difference {
        case 0:
            return .perfect
        case 1:
            return .good
        case 2:
            return .acceptable
        default:
            return .unbalanced
        }
    }

    // MARK: - Partner Suggestions

    /// Suggests best partners for a player based on past performance
    func suggestPartners(
        for player: Player,
        from players: [Player],
        basedOn results: [GameResult]
    ) -> [Player] {
        // Calculate win rate with each potential partner
        var partnerStats: [(player: Player, winRate: Double, gamesPlayed: Int)] = []

        for potentialPartner in players where potentialPartner.id != player.id {
            let record = calculateTeammateRecord(
                player1: player,
                player2: potentialPartner,
                results: results
            )

            if record.gamesPlayed > 0 {
                partnerStats.append((
                    player: potentialPartner,
                    winRate: record.winRate,
                    gamesPlayed: record.gamesPlayed
                ))
            }
        }

        // Sort by win rate, then by games played
        return partnerStats
            .sorted { stat1, stat2 in
                if stat1.winRate != stat2.winRate {
                    return stat1.winRate > stat2.winRate
                }
                return stat1.gamesPlayed > stat2.gamesPlayed
            }
            .map { $0.player }
    }

    private func calculateTeammateRecord(
        player1: Player,
        player2: Player,
        results: [GameResult]
    ) -> (winRate: Double, gamesPlayed: Int) {
        var gamesPlayed = 0
        var wins = 0

        for result in results {
            let p1OnTeam1 = result.team1PlayerIDs.contains(player1.id.uuidString)
            let p2OnTeam1 = result.team1PlayerIDs.contains(player2.id.uuidString)
            let p1OnTeam2 = result.team2PlayerIDs.contains(player1.id.uuidString)
            let p2OnTeam2 = result.team2PlayerIDs.contains(player2.id.uuidString)

            // Check if they were teammates
            if (p1OnTeam1 && p2OnTeam1) || (p1OnTeam2 && p2OnTeam2) {
                gamesPlayed += 1
                let wereOnTeam1 = p1OnTeam1 && p2OnTeam1
                if (wereOnTeam1 && result.winningTeam == 1) ||
                   (!wereOnTeam1 && result.winningTeam == 2) {
                    wins += 1
                }
            }
        }

        let winRate = gamesPlayed > 0 ? Double(wins) / Double(gamesPlayed) : 0
        return (winRate, gamesPlayed)
    }
}

enum MatchBalance: String {
    case perfect = "Perfect Match"
    case good = "Good Match"
    case acceptable = "Acceptable"
    case unbalanced = "Unbalanced"

    var description: String {
        switch self {
        case .perfect:
            return "Teams are perfectly balanced"
        case .good:
            return "Teams are well matched"
        case .acceptable:
            return "Teams have a slight skill difference"
        case .unbalanced:
            return "Consider adjusting teams for better balance"
        }
    }
}
