import XCTest
import SwiftData
@testable import StudyBuddy

@MainActor
final class FocusTimerModelTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([Avatar.self, Pet.self, FocusSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    func test_startSetsRemainingAndIsRunning() throws {
        let context = try makeContext()
        let model = FocusTimerModel()

        model.start(minutes: 25, context: context)

        XCTAssertEqual(model.remainingSeconds, 25 * 60)
        XCTAssertEqual(model.totalSeconds, 25 * 60)
        XCTAssertTrue(model.isRunning)

        model.pause()
    }

    func test_pauseClearsIsRunning() throws {
        let context = try makeContext()
        let model = FocusTimerModel()
        model.start(minutes: 15, context: context)

        model.pause()

        XCTAssertFalse(model.isRunning)
    }

    func test_resetZeroesState() throws {
        let context = try makeContext()
        let model = FocusTimerModel()
        model.start(minutes: 45, context: context)
        model.pause()

        model.reset()

        XCTAssertEqual(model.remainingSeconds, model.totalSeconds)
        XCTAssertFalse(model.isRunning)
    }
}
