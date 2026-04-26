import XCTest
@testable import StudyBuddy

@MainActor
final class StreakCalculatorTests: XCTestCase {

    private let calendar = Calendar(identifier: .gregorian)

    private func session(daysAgo: Int, completed: Bool = true, now: Date = .now) -> FocusSession {
        let start = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
        return FocusSession(startedAt: start, durationSeconds: 25 * 60, completed: completed)
    }

    func test_emptyReturnsZero() {
        XCTAssertEqual(
            StreakCalculator.currentStreak(sessions: [], calendar: calendar),
            0
        )
    }

    func test_threeDayConsecutiveStreak() {
        let now = Date()
        let sessions = [
            session(daysAgo: 0, now: now),
            session(daysAgo: 1, now: now),
            session(daysAgo: 2, now: now)
        ]
        XCTAssertEqual(
            StreakCalculator.currentStreak(sessions: sessions, calendar: calendar, now: now),
            3
        )
    }

    func test_yesterdayCountsIfNoSessionToday() {
        let now = Date()
        let sessions = [session(daysAgo: 1, now: now)]
        XCTAssertEqual(
            StreakCalculator.currentStreak(sessions: sessions, calendar: calendar, now: now),
            1
        )
    }

    func test_gapBreaksStreak() {
        let now = Date()
        let sessions = [
            session(daysAgo: 0, now: now),
            session(daysAgo: 2, now: now),
            session(daysAgo: 3, now: now)
        ]
        XCTAssertEqual(
            StreakCalculator.currentStreak(sessions: sessions, calendar: calendar, now: now),
            1
        )
    }

    func test_incompleteSessionsIgnored() {
        let now = Date()
        let sessions = [
            session(daysAgo: 0, completed: false, now: now),
            session(daysAgo: 1, now: now)
        ]
        XCTAssertEqual(
            StreakCalculator.currentStreak(sessions: sessions, calendar: calendar, now: now),
            1
        )
    }

    func test_longestAtLeastCurrent() {
        let now = Date()
        let sessions = [
            session(daysAgo: 0, now: now),
            session(daysAgo: 1, now: now),
            session(daysAgo: 5, now: now),
            session(daysAgo: 6, now: now),
            session(daysAgo: 7, now: now),
            session(daysAgo: 8, now: now)
        ]
        let current = StreakCalculator.currentStreak(sessions: sessions, calendar: calendar, now: now)
        let longest = StreakCalculator.longestStreak(sessions: sessions, calendar: calendar)
        XCTAssertGreaterThanOrEqual(longest, current)
        XCTAssertEqual(longest, 4)
    }
}
