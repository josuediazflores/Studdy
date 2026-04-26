import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var avatars: [Avatar]
    @Query private var inventories: [Inventory]
    @Query(sort: \Decoration.costTreats) private var decorations: [Decoration]
    @Query(sort: \FocusSession.startedAt, order: .reverse) private var sessions: [FocusSession]

    private var avatar: Avatar {
        if let existing = avatars.first { return existing }
        let new = Avatar.default
        modelContext.insert(new)
        try? modelContext.save()
        return new
    }

    private var inventory: Inventory {
        if let existing = inventories.first { return existing }
        let new = Inventory.default
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

    private var streak: Int {
        StreakCalculator.currentStreak(sessions: sessions)
    }

    private var weeklyProgress: WeeklyGoal.Progress {
        WeeklyGoal.progress(sessions: sessions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    AvatarView(avatar: avatar, size: 160, isHappy: avatarMood)
                        .padding(.vertical, 8)
                    weeklyGoalCard
                    statsCard
                    PetView()
                    DecorationStoreView()
                }
                .padding(20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(greeting)
                .font(Theme.Font.titleLarge)
                .foregroundStyle(Theme.accent)
            Text(avatarMood ? "Your buddy is happy to see you." : "Your buddy missed you — let's study!")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.accent.opacity(0.75))
            HStack(spacing: 8) {
                pill(systemImage: "leaf.fill", text: "\(inventory.treats) treats", tint: Theme.leaf)
                pill(systemImage: "flame.fill", text: "\(streak)-day streak", tint: Theme.danger)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var weeklyGoalCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Weekly goal")
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.accent)
                Spacer()
                Text("\(weeklyProgress.done) / \(weeklyProgress.target)")
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.accent)
                    .monospacedDigit()
            }
            ProgressView(value: weeklyProgress.fraction)
                .tint(Theme.primary)
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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

    private func pill(systemImage: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage).foregroundStyle(tint)
            Text(text)
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.accent)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Theme.surface)
        .clipShape(Capsule())
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

struct DecorationStoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var inventories: [Inventory]
    @Query(sort: \Decoration.costTreats) private var decorations: [Decoration]

    private var inventory: Inventory {
        if let existing = inventories.first { return existing }
        let new = Inventory.default
        modelContext.insert(new)
        try? modelContext.save()
        return new
    }

    private let columns = [GridItem(.adaptive(minimum: 130), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Decorate")
                    .font(Theme.Font.title)
                    .foregroundStyle(Theme.accent)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill").foregroundStyle(Theme.leaf)
                    Text("\(inventory.treats)")
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.accent)
                }
            }

            roomBackdrop

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(decorations) { decoration in
                    decorationTile(decoration)
                }
            }
        }
        .padding(16)
        .background(Theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var roomBackdrop: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.sky, Theme.secondary],
                startPoint: .top,
                endPoint: .bottom
            )
            HStack(spacing: 18) {
                ForEach(decorations.filter { $0.placed }) { d in
                    DecorationGlyph(decoration: d, size: 44)
                }
            }
            .padding()
            if decorations.filter({ $0.placed }).isEmpty {
                Text("Your cottage is empty — buy and place decorations!")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.accent.opacity(0.7))
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func decorationTile(_ decoration: Decoration) -> some View {
        VStack(spacing: 8) {
            DecorationGlyph(decoration: decoration, size: 48)
                .frame(height: 56)

            Text(decoration.name)
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.accent)
                .lineLimit(1)

            actionButton(for: decoration)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func actionButton(for decoration: Decoration) -> some View {
        if decoration.purchased {
            Button(action: { togglePlaced(decoration) }) {
                Text(decoration.placed ? "Unplace" : "Place")
                    .font(Theme.Font.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(decoration.placed ? Theme.accent : Theme.primary)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        } else {
            Button(action: { buy(decoration) }) {
                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                    Text("\(decoration.costTreats)")
                }
                .font(Theme.Font.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(canAfford(decoration) ? Theme.leaf : Theme.surface)
                .foregroundStyle(canAfford(decoration) ? Color.white : Theme.accent.opacity(0.5))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!canAfford(decoration))
        }
    }

    private func canAfford(_ d: Decoration) -> Bool {
        inventory.treats >= d.costTreats
    }

    private func buy(_ d: Decoration) {
        guard canAfford(d) else { return }
        inventory.treats -= d.costTreats
        d.purchased = true
        try? modelContext.save()
    }

    private func togglePlaced(_ d: Decoration) {
        d.placed.toggle()
        try? modelContext.save()
    }
}

struct DecorationGlyph: View {
    let decoration: Decoration
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            switch decoration.id {
            case "lamp":      lamp
            case "plant":     plant
            case "rug":       rug
            case "painting":  painting
            case "window":    window
            case "bookshelf": bookshelf
            default:          fallback
            }
        }
        .frame(width: size, height: size)
    }

    private var lamp: some View {
        VStack(spacing: 0) {
            Triangle().fill(Theme.primary).frame(width: size * 0.7, height: size * 0.45)
            Rectangle().fill(Theme.accent).frame(width: size * 0.1, height: size * 0.4)
            Capsule().fill(Theme.accent).frame(width: size * 0.5, height: size * 0.15)
        }
    }

    private var plant: some View {
        VStack(spacing: 0) {
            Image(systemName: "leaf.fill").font(.system(size: size * 0.5)).foregroundStyle(Theme.leaf)
            Rectangle().fill(Theme.primary).frame(width: size * 0.5, height: size * 0.3)
        }
    }

    private var rug: some View {
        Capsule().fill(Theme.danger).frame(width: size, height: size * 0.4)
            .overlay(Capsule().stroke(Theme.accent, lineWidth: 2))
    }

    private var painting: some View {
        ZStack {
            Rectangle().fill(Theme.accent).frame(width: size, height: size * 0.8)
            LinearGradient(colors: [Theme.primary, Theme.danger, Theme.sky],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: size * 0.85, height: size * 0.65)
        }
    }

    private var window: some View {
        ZStack {
            Rectangle().fill(Theme.accent)
                .frame(width: size, height: size)
            Rectangle().fill(Theme.sky)
                .frame(width: size * 0.85, height: size * 0.85)
            Rectangle().fill(Theme.accent).frame(width: 2, height: size * 0.85)
            Rectangle().fill(Theme.accent).frame(width: size * 0.85, height: 2)
        }
    }

    private var bookshelf: some View {
        VStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 1) {
                    Rectangle().fill(Theme.danger).frame(width: size * 0.12, height: size * 0.28)
                    Rectangle().fill(Theme.leaf).frame(width: size * 0.12, height: size * 0.28)
                    Rectangle().fill(Theme.primary).frame(width: size * 0.12, height: size * 0.28)
                    Rectangle().fill(Theme.sky).frame(width: size * 0.12, height: size * 0.28)
                }
            }
        }
        .padding(2)
        .background(Theme.accent)
    }

    private var fallback: some View {
        Image(systemName: "questionmark.square.dashed")
            .font(.system(size: size * 0.6))
            .foregroundStyle(Theme.accent)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    HomeView()
        .modelContainer(
            for: [Avatar.self, Pet.self, FocusSession.self, Inventory.self, Decoration.self],
            inMemory: true
        )
}
