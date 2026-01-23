import SwiftUI
import SwiftData

struct GameDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var game: Game

    @State private var showingShareSheet = false
    @State private var showingCancelAlert = false
    @State private var showingLogScore = false
    @State private var showingChat = false

    var body: some View {
        ScrollView {
            VStack(spacing: PickleballTheme.sectionSpacing) {
                // Header
                headerSection

                // Status Section
                statusSection

                // Time Options / Confirmed Time
                if game.status == .scheduling {
                    timeOptionsSection
                } else if let confirmedDate = game.confirmedDate {
                    confirmedTimeSection(date: confirmedDate)
                }

                // Location
                if let court = game.court {
                    locationSection(court: court)
                }

                // Players
                playersSection

                // Actions
                actionsSection

                // Chat preview
                if game.status != .cancelled {
                    chatPreviewSection
                }

                // Results (for completed games)
                if game.status == .completed, let results = game.results, !results.isEmpty {
                    resultsSection(results: results)
                }
            }
            .padding(PickleballTheme.pageMargin)
        }
        .pickleballBackground()
        .navigationTitle(game.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("Share Invite", systemImage: "square.and.arrow.up")
                    }

                    if game.status == .confirmed && !game.addedToCalendar {
                        Button {
                            addToCalendar()
                        } label: {
                            Label("Add to Calendar", systemImage: "calendar.badge.plus")
                        }
                    }

                    if game.status == .confirmed || game.status == .inProgress {
                        Button {
                            showingLogScore = true
                        } label: {
                            Label("Log Score", systemImage: "number.circle")
                        }
                    }

                    Divider()

                    if game.status != .cancelled && game.status != .completed {
                        Button(role: .destructive) {
                            showingCancelAlert = true
                        } label: {
                            Label("Cancel Game", systemImage: "xmark.circle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(PickleballTheme.courtGreen)
                }
            }
        }
        .alert("Cancel Game?", isPresented: $showingCancelAlert) {
            Button("Keep Game", role: .cancel) { }
            Button("Cancel Game", role: .destructive) {
                game.status = .cancelled
            }
        } message: {
            Text("All invited players will be notified.")
        }
        .sheet(isPresented: $showingLogScore) {
            LogScoreView(game: game)
        }
        .sheet(isPresented: $showingChat) {
            GameChatView(game: game)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            PickleballIcon(size: 56)

            VStack(spacing: 8) {
                Text(game.displayTitle)
                    .font(PickleballTheme.title)
                    .foregroundStyle(PickleballTheme.inkNavy)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Label(game.gameType.displayName, systemImage: "person.2")
                    Label("\(game.minimumPlayers) players", systemImage: "number.circle")
                }
                .font(PickleballTheme.caption)
                .foregroundStyle(PickleballTheme.inkMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .pickleballCard()
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Status")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            HStack {
                Image(systemName: game.status.iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(statusColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(game.status.displayName)
                        .font(PickleballTheme.serifFont(size: 16, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkNavy)

                    Text(statusDescription)
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)
                }

                Spacer()

                if game.status == .scheduling && game.hasEnoughPlayers {
                    Button("Confirm") {
                        confirmGame()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(16)
            .pickleballCard()
        }
    }

    private var statusColor: Color {
        switch game.status {
        case .scheduling: return PickleballTheme.warningAmber
        case .confirmed: return PickleballTheme.successGreen
        case .inProgress: return PickleballTheme.courtBlue
        case .completed: return PickleballTheme.inkMuted
        case .cancelled: return PickleballTheme.dangerRed
        }
    }

    private var statusDescription: String {
        switch game.status {
        case .scheduling:
            return "\(game.confirmedPlayerCount)/\(game.minimumPlayers) players confirmed"
        case .confirmed:
            return "Ready to play!"
        case .inProgress:
            return "Game is underway"
        case .completed:
            return "Game finished"
        case .cancelled:
            return "This game was cancelled"
        }
    }

    private var timeOptionsSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Proposed Times")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            if let options = game.timeOptions, !options.isEmpty {
                VStack(spacing: 8) {
                    ForEach(options.sorted(by: { $0.proposedDate < $1.proposedDate })) { option in
                        TimeOptionDetailRow(option: option)
                    }
                }
            } else {
                Text("No time options added")
                    .font(PickleballTheme.body)
                    .foregroundStyle(PickleballTheme.inkMuted)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .pickleballCard()
            }
        }
    }

    private func confirmedTimeSection(date: Date) -> some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Date & Time")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 24))
                    .foregroundStyle(PickleballTheme.courtGreen)

                VStack(alignment: .leading, spacing: 2) {
                    Text(date.formatted(date: .complete, time: .omitted))
                        .font(PickleballTheme.serifFont(size: 16, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkNavy)

                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(PickleballTheme.subheadline)
                        .foregroundStyle(PickleballTheme.inkMuted)
                }

                Spacer()

                if game.addedToCalendar {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(PickleballTheme.successGreen)
                }
            }
            .padding(16)
            .pickleballCard()
        }
    }

    private func locationSection(court: Court) -> some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Location")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            Button {
                if let url = court.mapsURL {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(PickleballTheme.courtGreen)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(court.name)
                            .font(PickleballTheme.serifFont(size: 16, weight: .medium))
                            .foregroundStyle(PickleballTheme.inkNavy)

                        Text(court.address)
                            .font(PickleballTheme.caption)
                            .foregroundStyle(PickleballTheme.inkMuted)

                        Text(court.displayDetails)
                            .font(PickleballTheme.caption)
                            .foregroundStyle(PickleballTheme.courtGreen)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(PickleballTheme.courtGreen)
                }
                .padding(16)
                .pickleballCard()
            }
            .buttonStyle(.plain)
        }
    }

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            HStack {
                Text("Players")
                    .font(PickleballTheme.smallCaps)
                    .foregroundStyle(PickleballTheme.inkMuted)

                Spacer()

                Text("\(game.confirmedPlayerCount)/\(game.minimumPlayers)")
                    .font(PickleballTheme.caption)
                    .foregroundStyle(PickleballTheme.inkMuted)
            }
            .padding(.horizontal, 4)

            if let players = game.players, !players.isEmpty {
                VStack(spacing: 8) {
                    ForEach(players) { player in
                        GamePlayerRow(player: player)
                    }
                }
            } else {
                Text("No players invited yet")
                    .font(PickleballTheme.body)
                    .foregroundStyle(PickleballTheme.inkMuted)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .pickleballCard()
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showingShareSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Invite Link")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            if game.status == .scheduling {
                Button {
                    // Find a 4th functionality
                } label: {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Find Available Players")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.top, 8)
    }

    private var chatPreviewSection: some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            HStack {
                Text("Chat")
                    .font(PickleballTheme.smallCaps)
                    .foregroundStyle(PickleballTheme.inkMuted)

                Spacer()

                Button("View All") {
                    showingChat = true
                }
                .font(PickleballTheme.caption)
                .foregroundStyle(PickleballTheme.courtGreen)
            }
            .padding(.horizontal, 4)

            Button {
                showingChat = true
            } label: {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .foregroundStyle(PickleballTheme.courtGreen)

                    if let messages = game.messages, !messages.isEmpty {
                        Text("\(messages.count) messages")
                            .font(PickleballTheme.body)
                            .foregroundStyle(PickleballTheme.inkCharcoal)
                    } else {
                        Text("Start a conversation")
                            .font(PickleballTheme.body)
                            .foregroundStyle(PickleballTheme.inkMuted)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkMuted.opacity(0.5))
                }
                .padding(16)
                .pickleballCard()
            }
            .buttonStyle(.plain)
        }
    }

    private func resultsSection(results: [GameResult]) -> some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text("Results")
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(results.sorted(by: { $0.matchNumber < $1.matchNumber })) { result in
                    HStack {
                        Text("Match \(result.matchNumber)")
                            .font(PickleballTheme.subheadline)
                            .foregroundStyle(PickleballTheme.inkNavy)

                        Spacer()

                        Text(result.scoreDisplay)
                            .font(PickleballTheme.serifFont(size: 18, weight: .medium))
                            .foregroundStyle(PickleballTheme.courtGreen)
                    }
                    .padding(12)
                    .pickleballCard()
                }
            }
        }
    }

    private func confirmGame() {
        guard let options = game.timeOptions,
              let bestOption = options.max(by: { $0.yesCount < $1.yesCount }) else { return }

        bestOption.isConfirmed = true
        game.confirmedDate = bestOption.proposedDate
        game.status = .confirmed
    }

    private func addToCalendar() {
        // Calendar integration would go here
        game.addedToCalendar = true
    }
}

struct TimeOptionDetailRow: View {
    let option: GameTimeOption

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(option.formattedDate)
                    .font(PickleballTheme.serifFont(size: 15, weight: .medium))
                    .foregroundStyle(PickleballTheme.inkNavy)

                Text(option.formattedTime)
                    .font(PickleballTheme.caption)
                    .foregroundStyle(PickleballTheme.inkMuted)
            }

            Spacer()

            HStack(spacing: 12) {
                RSVPCount(count: option.yesCount, status: .yes)
                RSVPCount(count: option.maybeCount, status: .maybe)
                RSVPCount(count: option.noCount, status: .no)
            }
        }
        .padding(12)
        .pickleballCard()
    }
}

struct RSVPCount: View {
    let count: Int
    let status: RSVPStatus

    var color: Color {
        switch status {
        case .yes: return PickleballTheme.successGreen
        case .no: return PickleballTheme.dangerRed
        case .maybe: return PickleballTheme.warningAmber
        case .pending: return PickleballTheme.inkMuted
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.system(size: 12))
            Text("\(count)")
                .font(PickleballTheme.caption)
        }
        .foregroundStyle(color)
    }
}

struct GamePlayerRow: View {
    let player: Player

    var body: some View {
        HStack(spacing: 12) {
            PlayerAvatar(player: player, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(PickleballTheme.serifFont(size: 15, weight: .medium))
                    .foregroundStyle(PickleballTheme.inkNavy)

                SkillBadge(level: player.skillLevel)
            }

            Spacer()
        }
        .padding(12)
        .pickleballCard()
    }
}

#Preview {
    NavigationStack {
        GameDetailView(game: Game(title: "Sunday Doubles", gameType: .doubles))
    }
    .modelContainer(for: [Game.self, Player.self, Court.self], inMemory: true)
}
