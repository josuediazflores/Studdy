import SwiftUI
import SwiftData

struct PetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [Pet]
    @State private var isDancing: Bool = false

    private var pet: Pet {
        if let existing = pets.first { return existing }
        let new = Pet.default
        modelContext.insert(new)
        try? modelContext.save()
        return new
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(pet.name)
                    .font(Theme.Font.title)
                    .foregroundStyle(Theme.accent)
                Spacer()
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
                Image(systemName: speciesSymbol)
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.accent)
                    .rotationEffect(isDancing ? .degrees(15) : .degrees(-15))
                    .animation(
                        isDancing
                            ? .easeInOut(duration: 0.4).repeatForever(autoreverses: true)
                            : .default,
                        value: isDancing
                    )
            }
            .frame(height: 120)

            statBars

            HStack {
                Button(action: feed) {
                    Label("Feed Treat", systemImage: "leaf.fill")
                        .font(Theme.Font.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Theme.leaf)
                        .foregroundStyle(Color.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

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

    private var speciesSymbol: String {
        switch pet.species {
        case "Mouse":     return "ant.fill"
        case "Dinosaur":  return "lizard.fill"
        case "Dog":       return "pawprint.fill"
        case "Cat":       return "cat.fill"
        default:          return "tortoise.fill"
        }
    }

    private var statBars: some View {
        VStack(spacing: 6) {
            statRow(label: "Mood", value: pet.mood, color: Theme.leaf)
            statRow(label: "Hunger", value: pet.hunger, color: Theme.danger)
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
        pet.hunger = max(pet.hunger - 15, 0)
        pet.mood = min(pet.mood + 5, 100)
        pet.lastFedAt = .now
        try? modelContext.save()
    }
}

#Preview {
    PetView()
        .modelContainer(for: [Avatar.self, Pet.self, FocusSession.self], inMemory: true)
}
