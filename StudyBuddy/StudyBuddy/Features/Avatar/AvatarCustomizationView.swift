import SwiftUI
import SwiftData

struct AvatarCustomizationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var avatars: [Avatar]

    private var avatar: Avatar {
        if let existing = avatars.first { return existing }
        let new = Avatar.default
        modelContext.insert(new)
        try? modelContext.save()
        return new
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        AvatarView(avatar: avatar, size: 160)
                        Spacer()
                    }
                    .listRowBackground(Theme.background)
                    .padding(.vertical, 12)
                }

                Section("Hair") {
                    Picker("Hair Style", selection: Binding(
                        get: { avatar.hairStyle },
                        set: { newValue in
                            avatar.hairStyle = newValue
                            try? modelContext.save()
                        }
                    )) {
                        ForEach(Avatar.hairOptions, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Outfit") {
                    Picker("Outfit", selection: Binding(
                        get: { avatar.outfit },
                        set: { newValue in
                            avatar.outfit = newValue
                            try? modelContext.save()
                        }
                    )) {
                        ForEach(Avatar.outfitOptions, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Accent Color") {
                    ColorPicker("Pick a color", selection: Binding(
                        get: { Theme.color(fromHex: avatar.accentColorHex) },
                        set: { newValue in
                            avatar.accentColorHex = Theme.hex(from: newValue)
                            try? modelContext.save()
                        }
                    ))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    AvatarCustomizationView()
        .modelContainer(
            for: [Avatar.self, Pet.self, FocusSession.self, Inventory.self, Decoration.self],
            inMemory: true
        )
}
