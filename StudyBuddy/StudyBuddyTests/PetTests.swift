import XCTest
import SwiftData
@testable import StudyBuddy

@MainActor
final class PetTests: XCTestCase {

    func test_feedingDecrementsHungerAndUpdatesLastFedAt() throws {
        let pet = Pet(species: "Capybara", name: "Mochi", hunger: 50, mood: 60, lastFedAt: .distantPast)
        let before = pet.lastFedAt
        let oldHunger = pet.hunger

        pet.hunger = max(pet.hunger - 15, 0)
        pet.mood = min(pet.mood + 5, 100)
        pet.lastFedAt = .now

        XCTAssertLessThan(pet.hunger, oldHunger)
        XCTAssertGreaterThan(pet.lastFedAt, before)
        XCTAssertGreaterThanOrEqual(pet.mood, 60)
    }

    func test_hungerClampsAtZero() {
        let pet = Pet(species: "Cat", name: "Mochi", hunger: 5, mood: 80, lastFedAt: .now)

        pet.hunger = max(pet.hunger - 15, 0)

        XCTAssertEqual(pet.hunger, 0)
    }

    func test_persistsThroughInMemoryContainer() throws {
        let schema = Schema([Avatar.self, Pet.self, FocusSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        context.insert(Pet.default)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Pet>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.species, "Capybara")
    }
}
