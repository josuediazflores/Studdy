import Foundation

enum StreakCalculator {
    static func currentStreak(
        sessions: [FocusSession],
        calendar: Calendar = .current,
        now: Date = .now
    ) -> Int {
        let completedDays = uniqueDays(sessions: sessions, calendar: calendar)
        guard !completedDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var anchor: Date
        if completedDays.contains(today) {
            anchor = today
        } else if completedDays.contains(yesterday) {
            anchor = yesterday
        } else {
            return 0
        }

        var streak = 0
        var cursor = anchor
        while completedDays.contains(cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    static func longestStreak(
        sessions: [FocusSession],
        calendar: Calendar = .current
    ) -> Int {
        let days = Array(uniqueDays(sessions: sessions, calendar: calendar)).sorted()
        guard !days.isEmpty else { return 0 }

        var longest = 1
        var current = 1
        for i in 1..<days.count {
            if let prev = calendar.date(byAdding: .day, value: 1, to: days[i - 1]),
               prev == days[i] {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    private static func uniqueDays(
        sessions: [FocusSession],
        calendar: Calendar
    ) -> Set<Date> {
        Set(sessions.filter { $0.completed }.map { calendar.startOfDay(for: $0.startedAt) })
    }
}
