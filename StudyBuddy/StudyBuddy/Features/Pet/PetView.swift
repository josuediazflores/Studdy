import SwiftUI
import SwiftData

struct PetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [Pet]
    @Query private var inventories: [Inventory]
    @State private var isDancing: Bool = false
    @State private var refreshTick: Date = .now

    private var pet: Pet {
        if let existing = pets.first { return existing }
        let new = Pet.default
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

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            content(at: context.date)
        }
    }

    private func content(at now: Date) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(pet.name)
                    .font(Theme.Font.title)
                    .foregroundStyle(Theme.accent)
                Spacer()
                treatsBadge
                Picker("Species", selection: Binding(
                    get: { pet.species },
                    set: { newValue in
                        pet.species = newValue
                        try? modelContext.save()
                    }
                )) {
                    ForEach(Pet.speciesOptions, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Theme.primary)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Theme.surface)
                PetSprite(species: pet.species, state: isDancing ? .dance : .idle)
                    .padding(12)
            }
            .frame(height: 160)

            statBars(now: now)

            HStack {
                Button(action: feed) {
                    Label(
                        inventory.treats > 0 ? "Feed Treat" : "No Treats",
                        systemImage: "leaf.fill"
                    )
                    .font(Theme.Font.body)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(inventory.treats > 0 ? Theme.leaf : Theme.surface)
                    .foregroundStyle(inventory.treats > 0 ? Color.white : Theme.accent.opacity(0.5))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(inventory.treats == 0)

                Button(action: { isDancing.toggle() }) {
                    Label(isDancing ? "Stop" : "Dance", systemImage: "music.note")
                        .font(Theme.Font.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Theme.primary)
                        .foregroundStyle(Color.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var treatsBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "leaf.fill")
                .foregroundStyle(Theme.leaf)
            Text("\(inventory.treats)")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.accent)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Theme.surface)
        .clipShape(Capsule())
    }

    private func statBars(now: Date) -> some View {
        VStack(spacing: 6) {
            statRow(label: "Mood", value: pet.currentMood(at: now), color: Theme.leaf)
            statRow(label: "Hunger", value: pet.currentHunger(at: now), color: Theme.danger)
        }
    }

    private func statRow(label: String, value: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.accent)
                .frame(width: 60, alignment: .leading)
            ProgressView(value: Double(min(max(value, 0), 100)) / 100.0)
                .tint(color)
        }
    }

    private func feed() {
        let ok = pet.feed(using: inventory)
        if ok {
            try? modelContext.save()
        }
    }
}

#Preview {
    PetView()
        .modelContainer(
            for: [Avatar.self, Pet.self, FocusSession.self, Inventory.self, Decoration.self],
            inMemory: true
        )
}
