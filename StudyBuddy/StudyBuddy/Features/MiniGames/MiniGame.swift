import SwiftUI

protocol MiniGame: Identifiable {
    var id: String { get }
    var title: String { get }
    var symbol: String { get }
    var summary: String { get }
    associatedtype Body: View
    @ViewBuilder func makeView() -> Body
}

struct AnyMiniGame: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let summary: String
    let view: () -> AnyView

    init<G: MiniGame>(_ game: G) {
        self.id = game.id
        self.title = game.title
        self.symbol = game.symbol
        self.summary = game.summary
        self.view = { AnyView(game.makeView()) }
    }
}

enum MiniGameRegistry {
    static let all: [AnyMiniGame] = [
        AnyMiniGame(MemoryMatchGame())
    ]
}
