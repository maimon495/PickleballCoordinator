import SwiftUI
import SwiftData

@main
struct PickleballCoordinatorApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Player.self,
                Game.self,
                GameTimeOption.self,
                Court.self,
                GameResult.self,
                ChatMessage.self,
                GamePhoto.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
