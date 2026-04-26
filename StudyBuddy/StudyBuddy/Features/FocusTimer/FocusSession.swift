import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var startedAt: Date
    var durationSeconds: Int
    var completed: Bool

    init(id: UUID = UUID(), startedAt: Date = .now, durationSeconds: Int, completed: Bool = false) {
        self.id = id
        self.startedAt = startedAt
        self.durationSeconds = durationSeconds
        self.completed = completed
    }
}
