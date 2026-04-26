import XCTest
@testable import StudyBuddy

@MainActor
final class PetDecayTests: XCTestCase {

    func test_hungerIncreasesOverTime() {
        let twoHoursAgo = Date().addingTimeInterval(-2 * 3600)
        let pet = Pet(species: "Capybara", name: "Mochi", hunger: 20, mood: 80, lastFedAt: twoHoursAgo)

        let h = pet.currentHunger()

        XCTAssertGreaterThan(h, 20)
        XCTAssertEqual(h, 30, accuracy: 1)
    }

    func test_hungerCapsAtHundred() {
        let monthAgo = Date().addingTimeInterval(-30 * 24 * 3600)
        let pet = Pet(species: "Capybara", name: "Mochi", hunger: 90, mood: 50, lastFedAt: monthAgo)

        XCTAssertEqual(pet.currentHunger(), 100)
    }

    func test_moodOnlyDropsWhenHungerHigh() {
        let recent = Date().addingTimeInterval(-30 * 60)
        let pet = Pet(species: "Capybara", name: "Mochi", hunger: 10, mood: 90, lastFedAt: recent)

        XCTAssertEqual(pet.currentMood(), 90)
    }

    func test_feedFailsWithNoTreats() {
        let pet = Pet(species: "Capybara", name: "Mochi", hunger: 60, mood: 60, lastFedAt: .distantPast)
        let inv = Inventory(treats: 0)

        let result = pet.feed(using: inv)

        XCTAssertFalse(result)
        XCTAssertEqual(inv.treats, 0)
    }

    func test_feedConsumesTreatAndReducesHunger() {
        let twoHoursAgo = Date().addingTimeInterval(-2 * 3600)
        let pet = Pet(species: "Capybara", name: "Mochi", hunger: 50, mood: 70, lastFedAt: twoHoursAgo)
        let inv = Inventory(treats: 3)
        let beforeHunger = pet.currentHunger()

        let result = pet.feed(using: inv)

        XCTAssertTrue(result)
        XCTAssertEqual(inv.treats, 2)
        XCTAssertLessThan(pet.hunger, beforeHunger)
    }
}
