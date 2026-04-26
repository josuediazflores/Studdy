import Foundation
import SwiftData

@Model
final class Inventory {
    var treats: Int

    init(treats: Int) {
        self.treats = treats
    }

    static var `default`: Inventory {
        Inventory(treats: 3)
    }
}
