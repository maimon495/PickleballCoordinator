import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \Player.gamesPlayed, order: .reverse) private var players: [Player]
    @Query(sort: \Game.createdAt, order: .reverse) private var games: [Game]

    var completedGames: [Game] {
        games.filter { $0.status == .completed }
    }

    var totalGamesPlayed: Int {
        completedGames.count
    }

    var thisMonthGames: Int {
        let calendar = Calendar.current
        let now = Date()
        return completedGames.filter {
            calendar.isDate($0.confirmedDate ?? $0.createdAt, equalTo: now, toGranularity: .month)
        }.count
    }

    var activePlayers: [Player] {
        players.filter { $0.gamesPlayed > 0 }.prefix(10).map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PickleballTheme.sectionSpacing) {
                    // Overview Stats
                    overviewSection

                    // Leaderboard
                    if !activePlayers.isEmpty {
                        leaderboardSection
                    }

                    // Recent Results
                    if !completedGames.isEmpty {
                        recentResultsSection
                    }

                    // Empty State
                    if players.isEmpty && games.isEmpty {
                        emptyState
                    }
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("Stats")
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Overview")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                OverviewStatCard(
                    title: "Total Games",
                    value: "\(totalGamesPlayed)",
                    icon: "flag.checkered"
                )

                OverviewStatCard(
                    title: "This Month",
                    value: "\(thisMonthGames)",
                    icon: "calendar"
                )

                OverviewStatCard(
                    title: "Players",
                    value: "\(players.count)",
                    icon: "person.2"
                )
            }
        }
    }

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Leaderboard")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(Array(activePlayers.enumerated()), id: \.element.id) { index, player in
                    LeaderboardRow(rank: index + 1, player: player)
                }
            }
        }
    }

    private var recentResultsSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Recent Games")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(completedGames.prefix(5)) { game in
                    RecentGameRow(game: game)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundStyle(PickleballTheme.inkMuted)

            Text("No Stats Yet")
                .font(PickleballTheme.headline)
                .foregroundStyle(PickleballTheme.inkNavy)

            Text("Complete some games to see your statistics here.")
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkMuted)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct OverviewStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(PickleballTheme.courtGreen)

            Text(value)
                .font(PickleballTheme.headline)
                .foregroundStyle(PickleballTheme.inkNavy)

            Text(title)
                .font(PickleballTheme.caption)
                .foregroundStyle(PickleballTheme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .pickleballCard()
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let player: Player

    var rankColor: Color {
        switch rank {
        case 1: return PickleballTheme.goldAccent
        case 2: return PickleballTheme.inkMuted
        case 3: return PickleballTheme.copperAccent
        default: return PickleballTheme.inkMuted.opacity(0.5)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 28, height: 28)

                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkMuted)
                        .frame(width: 28)
                }
            }

            PlayerAvatar(player: player, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(PickleballTheme.serifFont(size: 15, weight: .medium))
                    .foregroundStyle(PickleballTheme.inkNavy)

                HStack(spacing: 8) {
                    Text("\(player.gamesPlayed) games")
                    Text("·")
                    Text(player.winRatePercentage)
                }
                .font(PickleballTheme.caption)
                .foregroundStyle(PickleballTheme.inkMuted)
            }

            Spacer()

            // Win count
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(player.gamesWon)")
                    .font(PickleballTheme.headline)
                    .foregroundStyle(PickleballTheme.courtGreen)

                Text("wins")
                    .font(PickleballTheme.caption)
                    .foregroundStyle(PickleballTheme.inkMuted)
            }
        }
        .padding(12)
        .pickleballCard()
    }
}

struct RecentGameRow: View {
    let game: Game

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(game.displayTitle)
                    .font(PickleballTheme.serifFont(size: 15, weight: .medium))
                    .foregroundStyle(PickleballTheme.inkNavy)

                if let date = game.confirmedDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)
                }
            }

            Spacer()

            if let results = game.results, let lastResult = results.sorted(by: { $0.matchNumber > $1.matchNumber }).first {
                Text(lastResult.scoreDisplay)
                    .font(PickleballTheme.serifFont(size: 18, weight: .medium))
                    .foregroundStyle(PickleballTheme.courtGreen)
            }
        }
        .padding(12)
        .pickleballCard()
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [Player.self, Game.self], inMemory: true)
}
