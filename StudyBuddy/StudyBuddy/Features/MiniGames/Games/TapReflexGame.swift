import SwiftUI
import SwiftData

struct TapReflexGame: MiniGame {
    let id: String = "tap-reflex"
    let title: String = "Tap Reflex"
    let symbol: String = "hand.tap.fill"
    let summary: String = "Tap the leaf as fast as you can!"

    func makeView() -> some View {
        TapReflexGameView()
    }
}

struct TapReflexGameView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var score: Int = 0
    @State private var timeRemaining: Double = 20.0
    @State private var targetPosition: CGPoint = .zero
    @State private var phase: Phase = .ready
    @State private var awarded: Bool = false
    @State private var treatsAwarded: Int = 0

    enum Phase { case ready, playing, finished }

    private let duration: Double = 20.0
    private let tickInterval: Double = 0.05

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack {
                        Label("Score: \(score)", systemImage: "star.fill")
                            .foregroundStyle(Theme.primary)
                        Spacer()
                        Label(String(format: "%.1fs", timeRemaining), systemImage: "timer")
                            .foregroundStyle(Theme.accent)
                            .monospacedDigit()
                    }
                    .font(Theme.Font.body)
                    .padding(.horizontal)

                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Theme.surface)
                        switch phase {
                        case .ready:
                            VStack(spacing: 12) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 56))
                                    .foregroundStyle(Theme.primary)
                                Text("Tap Start, then catch the leaves")
                                    .font(Theme.Font.body)
                                    .foregroundStyle(Theme.accent)
                                Button("Start") { startGame(in: geo.size) }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Theme.primary)
                            }
                        case .playing:
                            Button(action: { hit(in: geo.size) }) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.white)
                                    .padding(18)
                                    .background(Theme.leaf)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .position(targetPosition)
                        case .finished:
                            VStack(spacing: 8) {
                                Text("Final score: \(score)")
                                    .font(Theme.Font.title)
                                    .foregroundStyle(Theme.accent)
                                Text("+\(treatsAwarded) treat\(treatsAwarded == 1 ? "" : "s")")
                                    .font(Theme.Font.title)
                                    .foregroundStyle(Theme.leaf)
                                Button("Play again") { reset() }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Theme.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Tap Reflex")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func startGame(in size: CGSize) {
        score = 0
        timeRemaining = duration
        phase = .playing
        awarded = false
        treatsAwarded = 0
        moveTarget(in: size)
        Task { @MainActor in
            while phase == .playing && timeRemaining > 0 {
                try? await Task.sleep(nanoseconds: UInt64(tickInterval * 1_000_000_000))
                if phase != .playing { return }
                timeRemaining -= tickInterval
                if timeRemaining <= 0 {
                    finish()
                }
            }
        }
    }

    private func hit(in size: CGSize) {
        guard phase == .playing else { return }
        score += 1
        moveTarget(in: size)
    }

    private func moveTarget(in size: CGSize) {
        let inset: CGFloat = 60
        let w = max(1, size.width - inset * 2)
        let h = max(1, size.height - inset * 2 - 80)
        targetPosition = CGPoint(
            x: CGFloat.random(in: inset...(inset + w)),
            y: CGFloat.random(in: 80...(80 + h))
        )
    }

    private func finish() {
        phase = .finished
        treatsAwarded = treatsForScore(score)
        guard !awarded else { return }
        awarded = true
        Rewards.awardTreats(treatsAwarded, in: modelContext)
    }

    private func treatsForScore(_ s: Int) -> Int {
        switch s {
        case ..<10:  return 1
        case 10..<20: return 2
        default:     return 3
        }
    }

    private func reset() {
        score = 0
        timeRemaining = duration
        phase = .ready
        awarded = false
        treatsAwarded = 0
    }
}

#Preview {
    NavigationStack { TapReflexGameView() }
        .modelContainer(
            for: [Avatar.self, Pet.self, FocusSession.self, Inventory.self, Decoration.self],
            inMemory: true
        )
}
