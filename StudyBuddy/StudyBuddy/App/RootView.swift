import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            FocusTimerView()
                .tabItem { Label("Timer", systemImage: "timer") }

            GameMenuView()
                .tabItem { Label("Games", systemImage: "gamecontroller.fill") }

            AvatarCustomizationView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                NotificationManager.shared.cancelPetMiss()
                Task { await NotificationManager.shared.requestAuthorizationOnce() }
            case .background:
                NotificationManager.shared.schedulePetMiss()
            default:
                break
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(
            for: [Avatar.self, Pet.self, FocusSession.self, Inventory.self, Decoration.self],
            inMemory: true
        )
}
