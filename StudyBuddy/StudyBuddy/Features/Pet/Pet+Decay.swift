import Foundation

extension Pet {
    func currentHunger(at now: Date = .now) -> Int {
        let elapsed = max(0, now.timeIntervalSince(lastFedAt))
        let gained = Int(elapsed / 720)
        return min(100, hunger + gained)
    }

    func currentMood(at now: Date = .now) -> Int {
        let h = currentHunger(at: now)
        guard h > 60 else { return min(100, max(0, mood)) }
        let elapsedHours = Int(max(0, now.timeIntervalSince(lastFedAt)) / 3600)
        let drop = elapsedHours
        return min(100, max(0, mood - drop))
    }

    @discardableResult
    func feed(using inventory: Inventory) -> Bool {
        guard inventory.treats > 0 else { return false }
        inventory.treats -= 1
        let baseHunger = currentHunger()
        let baseMood = currentMood()
        hunger = max(baseHunger - 25, 0)
        mood = min(baseMood + 8, 100)
        lastFedAt = .now
        return true
    }
}
