import Foundation
import SwiftData

enum Rewards {
    @discardableResult
    static func awardTreats(_ amount: Int, in context: ModelContext) -> Inventory {
        let inv = fetchOrCreateInventory(in: context)
        inv.treats += max(amount, 0)
        try? context.save()
        return inv
    }

    static func fetchOrCreateInventory(in context: ModelContext) -> Inventory {
        let descriptor = FetchDescriptor<Inventory>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let new = Inventory.default
        context.insert(new)
        try? context.save()
        return new
    }

    static func seedCatalogIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<Decoration>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            for item in Decoration.catalog {
                context.insert(item)
            }
            try? context.save()
        }
    }
}
