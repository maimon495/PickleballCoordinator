import SwiftUI
import SwiftData

struct LogScoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var game: Game

    @State private var team1Score: Int = 0
    @State private var team2Score: Int = 0
    @State private var team1Players: Set<Player> = []
    @State private var team2Players: Set<Player> = []

    var availablePlayers: [Player] {
        game.players ?? []
    }

    var matchNumber: Int {
        (game.results?.count ?? 0) + 1
    }

    var canSave: Bool {
        !team1Players.isEmpty && !team2Players.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PickleballTheme.sectionSpacing) {
                    // Match Header
                    Text("Match \(matchNumber)")
                        .font(PickleballTheme.title)
                        .foregroundStyle(PickleballTheme.inkNavy)
                        .padding(.top, 8)

                    // Score Entry
                    scoreSection

                    // Team Selection
                    teamSection(title: "Team 1", players: $team1Players, excludedPlayers: team2Players)
                    teamSection(title: "Team 2", players: $team2Players, excludedPlayers: team1Players)
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("Log Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(PickleballTheme.inkMuted)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveScore()
                    }
                    .foregroundStyle(canSave ? PickleballTheme.courtGreen : PickleballTheme.inkMuted)
                    .disabled(!canSave)
                }
            }
        }
    }

    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Score")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            HStack(spacing: 20) {
                // Team 1 Score
                VStack(spacing: 8) {
                    Text("Team 1")
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)

                    HStack {
                        Button {
                            if team1Score > 0 { team1Score -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(PickleballTheme.inkMuted)
                        }

                        Text("\(team1Score)")
                            .font(.system(size: 48, weight: .medium, design: .serif))
                            .foregroundStyle(PickleballTheme.inkNavy)
                            .frame(minWidth: 60)

                        Button {
                            team1Score += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(PickleballTheme.courtGreen)
                        }
                    }
                }

                Text("-")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(PickleballTheme.inkMuted)

                // Team 2 Score
                VStack(spacing: 8) {
                    Text("Team 2")
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)

                    HStack {
                        Button {
                            if team2Score > 0 { team2Score -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(PickleballTheme.inkMuted)
                        }

                        Text("\(team2Score)")
                            .font(.system(size: 48, weight: .medium, design: .serif))
                            .foregroundStyle(PickleballTheme.inkNavy)
                            .frame(minWidth: 60)

                        Button {
                            team2Score += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(PickleballTheme.courtGreen)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .pickleballCard()
        }
    }

    private func teamSection(title: String, players: Binding<Set<Player>>, excludedPlayers: Set<Player>) -> some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text(title)
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(availablePlayers.filter { !excludedPlayers.contains($0) }) { player in
                    Button {
                        if players.wrappedValue.contains(player) {
                            players.wrappedValue.remove(player)
                        } else {
                            players.wrappedValue.insert(player)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            PlayerAvatar(player: player, size: 36)

                            Text(player.name)
                                .font(PickleballTheme.serifFont(size: 15, weight: .medium))
                                .foregroundStyle(PickleballTheme.inkNavy)

                            Spacer()

                            if players.wrappedValue.contains(player) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(PickleballTheme.courtGreen)
                            } else {
                                Circle()
                                    .stroke(PickleballTheme.inkMuted.opacity(0.3), lineWidth: 1.5)
                                    .frame(width: 22, height: 22)
                            }
                        }
                        .padding(12)
                        .pickleballCard()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func saveScore() {
        let result = GameResult(
            matchNumber: matchNumber,
            team1Score: team1Score,
            team2Score: team2Score,
            team1PlayerIDs: team1Players.map { $0.id.uuidString },
            team2PlayerIDs: team2Players.map { $0.id.uuidString }
        )
        result.game = game

        if game.results == nil {
            game.results = []
        }
        game.results?.append(result)

        // Update player stats
        let winningTeam = result.winningTeam
        for player in team1Players {
            player.gamesPlayed += 1
            if winningTeam == 1 {
                player.gamesWon += 1
                player.currentStreak += 1
                if player.currentStreak > player.longestStreak {
                    player.longestStreak = player.currentStreak
                }
            } else if winningTeam == 2 {
                player.currentStreak = 0
            }
        }

        for player in team2Players {
            player.gamesPlayed += 1
            if winningTeam == 2 {
                player.gamesWon += 1
                player.currentStreak += 1
                if player.currentStreak > player.longestStreak {
                    player.longestStreak = player.currentStreak
                }
            } else if winningTeam == 1 {
                player.currentStreak = 0
            }
        }

        // Mark game as completed if this was the final match
        if game.status == .inProgress || game.status == .confirmed {
            game.status = .completed
        }

        dismiss()
    }
}

#Preview {
    LogScoreView(game: Game())
        .modelContainer(for: [Game.self, Player.self], inMemory: true)
}
