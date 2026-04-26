import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var avatars: [Avatar]
    @Query(sort: \FocusSession.startedAt, order: .reverse) private var sessions: [FocusSession]

    private var avatar: Avatar {
        if let existing = avatars.first { return existing }
        let new = Avatar.default
        modelContext.insert(new)
        try? modelContext.save()
        return new
    }

    private var todaysSessionCount: Int {
        let calendar = Calendar.current
        return sessions.filter {
            calendar.isDateInToday($0.startedAt) && $0.completed
        }.count
    }

    private var lastSessionMinutesAgo: String? {
        guard let last = sessions.first(where: { $0.completed }) else { return nil }
        let minutes = Int(Date().timeIntervalSince(last.startedAt) / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes) min ago" }
        let hours = minutes / 60
        return "\(hours) h ago"
    }

    private var avatarMood: Bool {
        guard let last = sessions.first(where: { $0.completed }) else { return true }
        let hoursSince = Date().timeIntervalSince(last.startedAt) / 3600
        return hoursSince < 6
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    AvatarView(avatar: avatar, size: 160, isHappy: avatarMood)
                        .padding(.vertical, 8)
                    statsCard
                    PetView()
                    EnvironmentDecorationView()
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(Theme.Font.titleLarge)
                .foregroundStyle(Theme.accent)
            Text(avatarMood ? "Your buddy is happy to see you." : "Your buddy missed you — let's study!")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.accent.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statsCard: some View {
        HStack(spacing: 12) {
            statTile(value: "\(todaysSessionCount)", label: "Today")
            statTile(value: "\(sessions.filter { $0.completed }.count)", label: "All time")
            statTile(value: lastSessionMinutesAgo ?? "—", label: "Last session")
        }
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.Font.title)
                .foregroundStyle(Theme.accent)
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.accent.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<18: return "Good afternoon"
        case 18..<22: return "Good evening"
        default:      return "Late night focus"
        }
    }
}

struct EnvironmentDecorationView: View {
    @State private var selectedTheme: String = "Cottage"
    private let themes = ["Cottage", "Forest", "Beach", "Library"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Decorate")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.accent)

            ZStack {
                LinearGradient(
                    colors: [Theme.sky, Theme.secondary],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image(systemName: backgroundSymbol)
                    .font(.system(size: 80))
                    .foregroundStyle(Theme.accent.opacity(0.6))
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(spacing: 8) {
                ForEach(themes, id: \.self) { themeName in
                    Button(action: { selectedTheme = themeName }) {
                        Text(themeName)
                            .font(Theme.Font.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedTheme == themeName ? Theme.primary : Theme.surface)
                            .foregroundStyle(selectedTheme == themeName ? Color.white : Theme.accent)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var backgroundSymbol: String {
        switch selectedTheme {
        case "Forest":  return "tree.fill"
        case "Beach":   return "beach.umbrella.fill"
        case "Library": return "books.vertical.fill"
        default:        return "house.fill"
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Avatar.self, Pet.self, FocusSession.self], inMemory: true)
}
