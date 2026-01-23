import SwiftUI
import SwiftData

struct PlayerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: PickleballTheme.sectionSpacing) {
                // Header
                headerSection

                // Stats Section
                if player.gamesPlayed > 0 {
                    statsSection
                }

                // Details Section
                detailsSection

                // Availability Section
                if !player.preferredDays.isEmpty {
                    availabilitySection
                }

                // Notes Section
                if !player.notes.isEmpty {
                    notesSection
                }

                // Recent Games Section
                if let games = player.games, !games.isEmpty {
                    recentGamesSection(games: games)
                }

                // Actions
                actionsSection
            }
            .padding(PickleballTheme.pageMargin)
        }
        .pickleballBackground()
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        player.isFavorite.toggle()
                    } label: {
                        Label(
                            player.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: player.isFavorite ? "star.slash" : "star"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(PickleballTheme.courtGreen)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPlayerView(player: player)
        }
        .alert("Delete Player?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(player)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            PlayerAvatar(player: player, size: 80)

            VStack(spacing: 4) {
                HStack {
                    Text(player.name)
                        .font(PickleballTheme.title)
                        .foregroundStyle(PickleballTheme.inkNavy)

                    if player.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(PickleballTheme.goldAccent)
                    }
                }

                SkillBadge(level: player.skillLevel)
            }

            if !player.phoneNumber.isEmpty {
                Button {
                    if let url = URL(string: "tel:\(player.phoneNumber)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                        Text(player.phoneNumber)
                    }
                    .font(PickleballTheme.subheadline)
                    .foregroundStyle(PickleballTheme.courtGreen)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .pickleballCard()
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Statistics")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                StatBox(title: "Games", value: "\(player.gamesPlayed)")
                StatBox(title: "Wins", value: "\(player.gamesWon)")
                StatBox(title: "Win Rate", value: player.winRatePercentage)
                StatBox(title: "Streak", value: "\(player.currentStreak)")
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Details")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                DetailRow(icon: "calendar", title: "Added", value: player.createdAt.formatted(date: .abbreviated, time: .omitted))

                Divider().padding(.leading, 44)

                DetailRow(icon: "trophy", title: "Best Streak", value: "\(player.longestStreak) wins")
            }
            .pickleballCard()
        }
    }

    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Preferred Days")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            HStack(spacing: 8) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    let index = ["S", "M", "T", "W", "T", "F", "S"].firstIndex(of: day)!
                    let dayNumber = index + 1

                    Text(day)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(
                            player.preferredDays.contains(dayNumber)
                            ? PickleballTheme.cream
                            : PickleballTheme.inkMuted
                        )
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(
                                    player.preferredDays.contains(dayNumber)
                                    ? PickleballTheme.courtGreen
                                    : PickleballTheme.cream
                                )
                        )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .pickleballCard()
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Notes")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            Text(player.notes)
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkCharcoal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .pickleballCard()
        }
    }

    private func recentGamesSection(games: [Game]) -> some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Recent Games")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(games.prefix(5)) { game in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(game.displayTitle)
                                .font(PickleballTheme.subheadline)
                                .foregroundStyle(PickleballTheme.inkNavy)

                            Text(game.formattedDate)
                                .font(PickleballTheme.caption)
                                .foregroundStyle(PickleballTheme.inkMuted)
                        }

                        Spacer()

                        GameStatusBadge(status: game.status)
                    }
                    .padding(12)
                    .pickleballCard()
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                if let url = URL(string: "sms:\(player.phoneNumber)") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Image(systemName: "message.fill")
                    Text("Send Message")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(player.phoneNumber.isEmpty)

            Button {
                // TODO: Navigate to create game with player pre-selected
            } label: {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Invite to Game")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.top, 8)
    }
}

struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(PickleballTheme.headline)
                .foregroundStyle(PickleballTheme.courtGreen)

            Text(title)
                .font(PickleballTheme.caption)
                .foregroundStyle(PickleballTheme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .pickleballCard()
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(PickleballTheme.courtGreen)
                .frame(width: 24)

            Text(title)
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkNavy)

            Spacer()

            Text(value)
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkMuted)
        }
        .padding(12)
    }
}

struct GameStatusBadge: View {
    let status: GameStatus

    var color: Color {
        switch status {
        case .scheduling: return PickleballTheme.warningAmber
        case .confirmed: return PickleballTheme.successGreen
        case .inProgress: return PickleballTheme.courtBlue
        case .completed: return PickleballTheme.inkMuted
        case .cancelled: return PickleballTheme.dangerRed
        }
    }

    var body: some View {
        Text(status.displayName)
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
    NavigationStack {
        PlayerDetailView(player: Player(name: "John Smith", phoneNumber: "555-1234", skillLevel: .intermediate))
    }
    .modelContainer(for: Player.self, inMemory: true)
}
