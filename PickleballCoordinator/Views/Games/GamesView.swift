import SwiftUI
import SwiftData

struct GamesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Game.createdAt, order: .reverse) private var games: [Game]
    @State private var showingCreateGame = false
    @State private var selectedFilter: GameFilter = .upcoming

    enum GameFilter: String, CaseIterable {
        case upcoming = "Upcoming"
        case past = "Past"
        case all = "All"
    }

    var filteredGames: [Game] {
        let now = Date()
        switch selectedFilter {
        case .upcoming:
            return games.filter { game in
                if let date = game.confirmedDate {
                    return date > now && game.status != .cancelled
                }
                return game.status == .scheduling || game.status == .confirmed
            }
        case .past:
            return games.filter { game in
                if let date = game.confirmedDate {
                    return date <= now || game.status == .completed
                }
                return game.status == .completed || game.status == .cancelled
            }
        case .all:
            return games
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PickleballTheme.sectionSpacing) {
                    // Filter Picker
                    filterPicker

                    if filteredGames.isEmpty {
                        emptyState
                    } else {
                        gamesList
                    }
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateGame = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(PickleballTheme.courtGreen)
                    }
                }
            }
            .sheet(isPresented: $showingCreateGame) {
                CreateGameView()
            }
        }
    }

    private var filterPicker: some View {
        HStack(spacing: 0) {
            ForEach(GameFilter.allCases, id: \.self) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(PickleballTheme.serifFont(size: 14, weight: .medium))
                        .foregroundStyle(
                            selectedFilter == filter
                            ? PickleballTheme.cream
                            : PickleballTheme.inkCharcoal
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            selectedFilter == filter
                            ? PickleballTheme.courtGreen
                            : Color.clear
                        )
                }
            }
        }
        .background(PickleballTheme.cream)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(PickleballTheme.courtGreen.opacity(0.2), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            PickleballIcon(size: 64, color: PickleballTheme.inkMuted.opacity(0.5))

            Text(selectedFilter == .upcoming ? "No Upcoming Games" : "No Games Yet")
                .font(PickleballTheme.headline)
                .foregroundStyle(PickleballTheme.inkNavy)

            Text(selectedFilter == .upcoming
                 ? "Schedule a game with your friends to get started."
                 : "Create your first game to start coordinating.")
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkMuted)
                .multilineTextAlignment(.center)

            Button("Create Game") {
                showingCreateGame = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 8)
        }
        .padding(40)
    }

    private var gamesList: some View {
        VStack(spacing: 12) {
            ForEach(filteredGames) { game in
                NavigationLink(destination: GameDetailView(game: game)) {
                    GameRow(game: game)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct GameRow: View {
    let game: Game
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.displayTitle)
                        .font(PickleballTheme.serifFont(size: 17, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkNavy)

                    if let court = game.court {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 11))
                            Text(court.name)
                        }
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)
                    }
                }

                Spacer()

                GameStatusBadge(status: game.status)
            }

            HStack(spacing: 16) {
                // Date/Time
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundStyle(PickleballTheme.courtGreen)
                    Text(game.formattedDate)
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkCharcoal)
                }

                // Player count
                HStack(spacing: 6) {
                    Image(systemName: "person.2")
                        .foregroundStyle(PickleballTheme.courtGreen)
                    Text("\(game.confirmedPlayerCount)/\(game.minimumPlayers)")
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkCharcoal)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(PickleballTheme.inkMuted.opacity(0.5))
            }
        }
        .padding(16)
        .pickleballCard()
    }
}

#Preview {
    GamesView()
        .modelContainer(for: [Game.self, Player.self, Court.self], inMemory: true)
}
