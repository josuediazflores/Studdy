import XCTest
import SwiftData
@testable import StudyBuddy

@MainActor
final class RewardsTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([Avatar.self, Pet.self, FocusSession.self, Inventory.self, Decoration.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    func test_firstAwardCreatesInventoryAtDefaultPlusReward() throws {
        let context = try makeContext()

        let inv = Rewards.awardTreats(2, in: context)

        XCTAssertEqual(inv.treats, Inventory.default.treats + 2)

        let fetched = try context.fetch(FetchDescriptor<Inventory>())
        XCTAssertEqual(fetched.count, 1)
    }

    func test_secondAwardIncrementsExisting() throws {
        let context = try makeContext()

        Rewards.awardTreats(1, in: context)
        let inv = Rewards.awardTreats(3, in: context)

        XCTAssertEqual(inv.treats, Inventory.default.treats + 4)

        let count = try context.fetchCount(FetchDescriptor<Inventory>())
        XCTAssertEqual(count, 1)
    }

    func test_seedCatalogInsertsOnce() throws {
        let context = try makeContext()

        Rewards.seedCatalogIfNeeded(in: context)
        Rewards.seedCatalogIfNeeded(in: context)

        let count = try context.fetchCount(FetchDescriptor<Decoration>())
        XCTAssertEqual(count, Decoration.catalog.count)
    }

    func test_negativeAwardIsIgnored() throws {
        let context = try makeContext()

        let inv = Rewards.awardTreats(-5, in: context)

        XCTAssertEqual(inv.treats, Inventory.default.treats)
    }
}
