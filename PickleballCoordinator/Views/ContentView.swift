import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GamesView()
                .tabItem {
                    Label("Games", systemImage: "calendar")
                }
                .tag(0)

            PlayersView()
                .tabItem {
                    Label("Players", systemImage: "person.2")
                }
                .tag(1)

            CourtsView()
                .tabItem {
                    Label("Courts", systemImage: "mappin.and.ellipse")
                }
                .tag(2)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(3)
        }
        .tint(PickleballTheme.courtGreen)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Player.self, Game.self, Court.self], inMemory: true)
}
