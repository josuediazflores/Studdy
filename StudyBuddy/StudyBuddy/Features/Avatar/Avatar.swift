import Foundation
import SwiftData

@Model
final class Avatar {
    var hairStyle: String
    var outfit: String
    var accentColorHex: String

    init(hairStyle: String, outfit: String, accentColorHex: String) {
        self.hairStyle = hairStyle
        self.outfit = outfit
        self.accentColorHex = accentColorHex
    }

    static var `default`: Avatar {
        Avatar(hairStyle: "Bun", outfit: "Cozy Sweater", accentColorHex: "#D58E60")
    }

    static let hairOptions: [String] = ["Bun", "Pigtails", "Long", "Short", "Braid"]
    static let outfitOptions: [String] = ["Cozy Sweater", "Overalls", "Hoodie", "Dress", "Pajamas"]
}
