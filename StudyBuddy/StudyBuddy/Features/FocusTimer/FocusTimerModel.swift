import Foundation
import Observation
import SwiftData

@Observable
final class FocusTimerModel {
    var totalSeconds: Int = 25 * 60
    var remainingSeconds: Int = 25 * 60
    var isRunning: Bool = false

    @ObservationIgnored private var tickTask: Task<Void, Never>?
    @ObservationIgnored private var sessionStartedAt: Date?

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(remainingSeconds) / Double(totalSeconds)
    }

    func start(minutes: Int, context: ModelContext) {
        if !isRunning {
            if remainingSeconds == 0 || sessionStartedAt == nil {
                totalSeconds = minutes * 60
                remainingSeconds = totalSeconds
                sessionStartedAt = .now
            }
            isRunning = true
            scheduleTicks(context: context)
        }
    }

    func resume(context: ModelContext) {
        guard !isRunning, remainingSeconds > 0 else { return }
        isRunning = true
        scheduleTicks(context: context)
    }

    func pause() {
        isRunning = false
        tickTask?.cancel()
        tickTask = nil
    }

    func reset() {
        pause()
        remainingSeconds = totalSeconds
        sessionStartedAt = nil
    }

    func tick(context: ModelContext) {
        guard isRunning else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }
        if remainingSeconds == 0 {
            complete(context: context)
        }
    }

    private func scheduleTicks(context: ModelContext) {
        tickTask?.cancel()
        tickTask = Task { @MainActor [weak self] in
            while let self, self.isRunning, self.remainingSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                self.tick(context: context)
            }
        }
    }

    private func complete(context: ModelContext) {
        isRunning = false
        tickTask?.cancel()
        tickTask = nil
        let session = FocusSession(
            startedAt: sessionStartedAt ?? .now,
            durationSeconds: totalSeconds,
            completed: true
        )
        context.insert(session)
        try? context.save()
        sessionStartedAt = nil
    }
}
