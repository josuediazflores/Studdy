import Foundation
import SwiftData

@Model
final class Decoration {
    @Attribute(.unique) var id: String
    var name: String
    var theme: String
    var costTreats: Int
    var purchased: Bool
    var placed: Bool

    init(id: String, name: String, theme: String, costTreats: Int, purchased: Bool = false, placed: Bool = false) {
        self.id = id
        self.name = name
        self.theme = theme
        self.costTreats = costTreats
        self.purchased = purchased
        self.placed = placed
    }

    static let catalog: [Decoration] = [
        Decoration(id: "lamp",       name: "Cozy Lamp",     theme: "Cottage", costTreats: 2),
        Decoration(id: "plant",      name: "Potted Plant",  theme: "Cottage", costTreats: 3),
        Decoration(id: "rug",        name: "Woven Rug",     theme: "Cottage", costTreats: 4),
        Decoration(id: "painting",   name: "Sunset Art",    theme: "Cottage", costTreats: 5),
        Decoration(id: "window",     name: "Sunny Window",  theme: "Cottage", costTreats: 6),
        Decoration(id: "bookshelf",  name: "Bookshelf",     theme: "Cottage", costTreats: 8),
    ]
}
