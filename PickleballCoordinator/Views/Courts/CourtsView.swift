import SwiftUI
import SwiftData

struct CourtsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Court.name) private var courts: [Court]
    @State private var showingAddCourt = false
    @State private var searchText = ""

    var filteredCourts: [Court] {
        if searchText.isEmpty {
            return courts
        }
        return courts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }

    var favoriteCourts: [Court] {
        filteredCourts.filter { $0.isFavorite }
    }

    var otherCourts: [Court] {
        filteredCourts.filter { !$0.isFavorite }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PickleballTheme.sectionSpacing) {
                    if courts.isEmpty {
                        emptyState
                    } else {
                        if !favoriteCourts.isEmpty {
                            courtSection(title: "Favorites", courts: favoriteCourts)
                        }

                        if !otherCourts.isEmpty {
                            courtSection(title: "All Courts", courts: otherCourts)
                        }
                    }
                }
                .padding(PickleballTheme.pageMargin)
            }
            .pickleballBackground()
            .navigationTitle("Courts")
            .searchable(text: $searchText, prompt: "Search courts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddCourt = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(PickleballTheme.courtGreen)
                    }
                }
            }
            .sheet(isPresented: $showingAddCourt) {
                AddCourtView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48))
                .foregroundStyle(PickleballTheme.inkMuted)

            Text("No Courts Yet")
                .font(PickleballTheme.headline)
                .foregroundStyle(PickleballTheme.inkNavy)

            Text("Save your favorite pickleball courts for quick access.")
                .font(PickleballTheme.body)
                .foregroundStyle(PickleballTheme.inkMuted)
                .multilineTextAlignment(.center)

            Button("Add Court") {
                showingAddCourt = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 8)
        }
        .padding(40)
    }

    private func courtSection(title: String, courts: [Court]) -> some View {
        VStack(alignment: .leading, spacing: PickleballTheme.itemSpacing) {
            Text(title)
                .font(PickleballTheme.smallCaps)
                .foregroundStyle(PickleballTheme.inkMuted)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(courts) { court in
                    NavigationLink(destination: CourtDetailView(court: court)) {
                        CourtRow(court: court)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct CourtRow: View {
    let court: Court
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(PickleballTheme.courtGreen)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(court.name)
                        .font(PickleballTheme.serifFont(size: 16, weight: .medium))
                        .foregroundStyle(PickleballTheme.inkNavy)

                    if court.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(PickleballTheme.goldAccent)
                    }
                }

                Text(court.address)
                    .font(PickleballTheme.caption)
                    .foregroundStyle(PickleballTheme.inkMuted)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if court.numberOfCourts > 1 {
                        Label("\(court.numberOfCourts)", systemImage: "square.grid.2x2")
                    }
                    if court.isIndoor {
                        Label("Indoor", systemImage: "building.2")
                    }
                    if court.hasLights {
                        Label("Lights", systemImage: "lightbulb")
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(PickleballTheme.inkMuted)
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
                modelContext.delete(court)
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                court.isFavorite.toggle()
            } label: {
                Label(
                    court.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: court.isFavorite ? "star.slash" : "star"
                )
            }
            .tint(PickleballTheme.goldAccent)
        }
    }
}

#Preview {
    CourtsView()
        .modelContainer(for: Court.self, inMemory: true)
}
