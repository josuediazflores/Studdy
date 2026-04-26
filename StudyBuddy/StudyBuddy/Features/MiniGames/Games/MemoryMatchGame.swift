import SwiftUI

struct MemoryMatchGame: MiniGame {
    let id: String = "memory-match"
    let title: String = "Memory Match"
    let symbol: String = "rectangle.grid.2x2.fill"
    let summary: String = "Flip cards and match the pairs."

    func makeView() -> some View {
        MemoryMatchGameView()
    }
}

private struct MemoryCard: Identifiable, Equatable {
    let id: Int
    let symbol: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct MemoryMatchGameView: View {
    @State private var cards: [MemoryCard] = MemoryMatchGameView.makeDeck()
    @State private var firstFlippedIndex: Int? = nil
    @State private var matchesFound: Int = 0
    @State private var moves: Int = 0
    @State private var isResolving: Bool = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    private static let symbols = ["leaf.fill", "sun.max.fill", "moon.fill", "drop.fill",
                                  "flame.fill", "snowflake", "star.fill", "heart.fill"]

    private var allMatched: Bool { matchesFound == cards.count / 2 }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Matches: \(matchesFound)", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Theme.leaf)
                Spacer()
                Label("Moves: \(moves)", systemImage: "hand.tap.fill")
                    .foregroundStyle(Theme.accent)
            }
            .font(Theme.Font.body)
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    Button {
                        flip(at: index)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(card.isMatched ? Theme.leaf.opacity(0.4)
                                      : (card.isFaceUp ? Theme.surface : Theme.primary))
                            if card.isFaceUp || card.isMatched {
                                Image(systemName: card.symbol)
                                    .font(.system(size: 30))
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .disabled(card.isFaceUp || card.isMatched || isResolving)
                }
            }
            .padding()

            if allMatched {
                VStack(spacing: 6) {
                    Text("Treat earned!")
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.leaf)
                    Button("Play again") { reset() }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.primary)
                }
                .padding()
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 8)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Memory Match")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset", action: reset)
            }
        }
    }

    private func flip(at index: Int) {
        guard !cards[index].isFaceUp, !cards[index].isMatched, !isResolving else { return }
        cards[index].isFaceUp = true

        if let first = firstFlippedIndex {
            moves += 1
            if cards[first].symbol == cards[index].symbol {
                cards[first].isMatched = true
                cards[index].isMatched = true
                matchesFound += 1
                firstFlippedIndex = nil
            } else {
                isResolving = true
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 700_000_000)
                    cards[first].isFaceUp = false
                    cards[index].isFaceUp = false
                    firstFlippedIndex = nil
                    isResolving = false
                }
            }
        } else {
            firstFlippedIndex = index
        }
    }

    private func reset() {
        cards = MemoryMatchGameView.makeDeck()
        firstFlippedIndex = nil
        matchesFound = 0
        moves = 0
        isResolving = false
    }

    private static func makeDeck() -> [MemoryCard] {
        let pairs = symbols.flatMap { [$0, $0] }
        return pairs.shuffled().enumerated().map { MemoryCard(id: $0.offset, symbol: $0.element) }
    }
}

#Preview {
    NavigationStack { MemoryMatchGameView() }
}
