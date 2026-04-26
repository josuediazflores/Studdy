import SwiftUI

struct RootView: View {
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
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Avatar.self, Pet.self, FocusSession.self], inMemory: true)
}
