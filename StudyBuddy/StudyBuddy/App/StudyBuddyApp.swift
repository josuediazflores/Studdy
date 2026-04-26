import SwiftUI
import SwiftData

@main
struct StudyBuddyApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: Avatar.self, Pet.self, FocusSession.self
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Theme.primary)
        }
        .modelContainer(container)
    }
}
