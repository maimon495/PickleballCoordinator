import SwiftUI
import SwiftData

struct PlayerPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.name) private var players: [Player]
    @Binding var selectedPlayers: Set<Player>
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
            .navigationTitle("Select Players")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search players")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(PickleballTheme.inkMuted)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(PickleballTheme.courtGreen)
                }
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

            Text("Add players in the Players tab first.")
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkMuted)
                .multilineTextAlignment(.center)
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
                    PlayerPickerRow(
                        player: player,
                        isSelected: selectedPlayers.contains(player)
                    ) {
                        if selectedPlayers.contains(player) {
                            selectedPlayers.remove(player)
                        } else {
                            selectedPlayers.insert(player)
                        }
                    }
                }
            }
        }
    }
}

struct PlayerPickerRow: View {
    let player: Player
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                PlayerAvatar(player: player, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(player.name)
                            .font(PickleballTheme.serifFont(size: 15, weight: .medium))
                            .foregroundStyle(PickleballTheme.inkNavy)

                        if player.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(PickleballTheme.goldAccent)
                        }
                    }

                    SkillBadge(level: player.skillLevel)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PickleballTheme.courtGreen)
                        .font(.system(size: 22))
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

#Preview {
    PlayerPickerView(selectedPlayers: .constant([]))
        .modelContainer(for: Player.self, inMemory: true)
}
