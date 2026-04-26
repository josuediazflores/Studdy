import Foundation

enum WeeklyGoal {
    static let target: Int = 5

    struct Progress {
        let done: Int
        let target: Int
        var fraction: Double {
            guard target > 0 else { return 0 }
            return min(1.0, Double(done) / Double(target))
        }
    }

    static func progress(
        sessions: [FocusSession],
        calendar: Calendar = .current,
        now: Date = .now
    ) -> Progress {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return Progress(done: 0, target: target)
        }
        let count = sessions.filter {
            $0.completed && week.contains($0.startedAt)
        }.count
        return Progress(done: count, target: target)
    }
}
