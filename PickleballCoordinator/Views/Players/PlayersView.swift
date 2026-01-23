import SwiftUI
import SwiftData

struct PlayersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Player.name) private var players: [Player]
    @State private var showingAddPlayer = false
    @State private var searchText = ""

    var filteredPlayers: [Player] {
        if searchText.isEmpty {
            return players
        }
        return players.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var favoritePlayers: [Player] {
        filteredPlayers.filter { $0.isFavorite }
    }

    var otherPlayers: [Player] {
        filteredPlayers.filter { !$0.isFavorite }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PickleballTheme.sectionSpacing) {
                    if players.isEmpty {
                        emptyState
                    } else {
                        if !favoritePlayers.isEmpty {
                            playerSection(title: "Favorites", players: favoritePlayers)
                        }

                        if !otherPlayers.isEmpty {
                            playerSection(title: "All Players", players: otherPlayers)
                        }
                    }
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("Players")
            .searchable(text: $searchText, prompt: "Search players")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPlayer = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(PickleballTheme.courtGreen)
                    }
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 48))
                .foregroundStyle(PickleballTheme.inkMuted)

            Text("No Players Yet")
                .font(PickleballTheme.headline)
                .foregroundStyle(PickleballTheme.inkNavy)

            Text("Add your pickleball friends to start coordinating games.")
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkMuted)
                .multilineTextAlignment(.center)

            Button("Add Player") {
                showingAddPlayer = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 8)
        }
        .padding(40)
    }

    private func playerSection(title: String, players: [Player]) -> some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text(title)
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(players) { player in
                    NavigationLink(destination: PlayerDetailView(player: player)) {
                        PlayerRow(player: player)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct PlayerRow: View {
    let player: Player
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            PlayerAvatar(player: player, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(player.name)
                        .font(PickleballTheme.serifFont(size: 16, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkNavy)

                    if player.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(PickleballTheme.goldAccent)
                    }
                }

                HStack(spacing: 8) {
                    SkillBadge(level: player.skillLevel)

                    if player.gamesPlayed > 0 {
                        Text("\(player.gamesPlayed) games")
                            .font(PickleballTheme.caption)
                            .foregroundStyle(PickleballTheme.inkMuted)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(PickleballTheme.inkMuted.opacity(0.5))
        }
        .padding(12)
        .pickleballCard()
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(player)
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                player.isFavorite.toggle()
            } label: {
                Label(
                    player.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: player.isFavorite ? "star.slash" : "star"
                )
            }
            .tint(PickleballTheme.goldAccent)
        }
    }
}

struct PlayerAvatar: View {
    let player: Player
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(
                    red: player.avatarColor.color.red,
                    green: player.avatarColor.color.green,
                    blue: player.avatarColor.color.blue
                ))

            Text(player.initials)
                .font(.system(size: size * 0.4, weight: .medium, design: .serif))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

struct SkillBadge: View {
    let level: SkillLevel

    var color: Color {
        switch level {
        case .beginner: return PickleballTheme.beginnerColor
        case .intermediate: return PickleballTheme.intermediateColor
        case .advanced: return PickleballTheme.advancedColor
        }
    }

    var body: some View {
        Text(level.displayName)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }
}

#Preview {
    PlayersView()
        .modelContainer(for: Player.self, inMemory: true)
}
