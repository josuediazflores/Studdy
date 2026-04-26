import XCTest
@testable import StudyBuddy

@MainActor
final class WeeklyGoalTests: XCTestCase {

    private let calendar = Calendar(identifier: .gregorian)

    private func session(daysAgo: Int, completed: Bool = true, now: Date = .now) -> FocusSession {
        let start = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
        return FocusSession(startedAt: start, durationSeconds: 25 * 60, completed: completed)
    }

    func test_emptyZeroOverTarget() {
        let p = WeeklyGoal.progress(sessions: [], calendar: calendar)
        XCTAssertEqual(p.done, 0)
        XCTAssertEqual(p.target, WeeklyGoal.target)
    }

    func test_countsCompletedSessionsInThisWeek() {
        let now = Date()
        let sessions = [
            session(daysAgo: 0, now: now),
            session(daysAgo: 1, now: now),
            session(daysAgo: 30, now: now),
            session(daysAgo: 0, completed: false, now: now)
        ]

        let p = WeeklyGoal.progress(sessions: sessions, calendar: calendar, now: now)

        XCTAssertGreaterThanOrEqual(p.done, 1)
        XCTAssertLessThanOrEqual(p.done, 2)
        XCTAssertLessThan(p.fraction, 1.5)
    }

    func test_fractionClampsAtOne() {
        let now = Date()
        let many = (0..<20).map { _ in session(daysAgo: 0, now: now) }
        let p = WeeklyGoal.progress(sessions: many, calendar: calendar, now: now)
        XCTAssertEqual(p.fraction, 1.0)
    }
}
