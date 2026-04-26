import SwiftUI
import SwiftData

struct WordScrambleGame: MiniGame {
    let id: String = "word-scramble"
    let title: String = "Word Scramble"
    let summary: String = "Unscramble cozy words for treats."
    let symbol: String = "textformat.abc"

    func makeView() -> some View {
        WordScrambleGameView()
    }
}

struct WordScrambleGameView: View {
    @Environment(\.modelContext) private var modelContext

    private static let words = ["TEAPOT", "GARDEN", "CANDLE", "BOOKS", "MEADOW", "FOREST", "AUTUMN", "QUILT"]

    @State private var word: String = ""
    @State private var scrambled: String = ""
    @State private var guess: String = ""
    @State private var solvedCount: Int = 0
    @State private var startedAt: Date = .now
    @State private var phase: Phase = .playing
    @State private var awarded: Bool = false
    @State private var treatsAwarded: Int = 0

    enum Phase { case playing, finished }

    private let target: Int = 5

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 18) {
                progressHeader

                switch phase {
                case .playing:
                    playingView
                case .finished:
                    finishedView
                }

                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .navigationTitle("Word Scramble")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if word.isEmpty { newPuzzle() } }
    }

    private var progressHeader: some View {
        HStack {
            Label("\(solvedCount)/\(target)", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Theme.leaf)
            Spacer()
            Label(elapsedString, systemImage: "stopwatch")
                .foregroundStyle(Theme.accent)
                .monospacedDigit()
        }
        .font(Theme.Font.body)
    }

    private var playingView: some View {
        VStack(spacing: 16) {
            Text(scrambled)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .tracking(6)
                .foregroundStyle(Theme.accent)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            TextField("Your guess", text: $guess)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled(true)
                .font(Theme.Font.title)
                .padding()
                .background(Theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.surface, lineWidth: 2)
                )
                .onSubmit { submit() }

            HStack(spacing: 12) {
                Button("Skip") { newPuzzle() }
                    .buttonStyle(.bordered)
                    .tint(Theme.accent)

                Button("Submit") { submit() }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primary)
                    .disabled(guess.isEmpty)
            }
        }
    }

    private var finishedView: some View {
        VStack(spacing: 8) {
            Text("Done in \(elapsedString)")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.accent)
            Text("+\(treatsAwarded) treat\(treatsAwarded == 1 ? "" : "s")")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.leaf)
            Button("Play again") { restart() }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
        }
        .padding()
    }

    private var elapsedString: String {
        let elapsed = Int(Date().timeIntervalSince(startedAt))
        let m = elapsed / 60
        let s = elapsed % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func newPuzzle() {
        let pick = WordScrambleGameView.words.randomElement() ?? "STUDY"
        word = pick
        scrambled = scramble(pick)
        guess = ""
    }

    private func scramble(_ s: String) -> String {
        var chars = Array(s)
        for _ in 0..<10 { chars.shuffle() }
        if String(chars) == s { chars.reverse() }
        return String(chars)
    }

    private func submit() {
        guard guess.uppercased() == word else {
            guess = ""
            return
        }
        solvedCount += 1
        if solvedCount >= target {
            finish()
        } else {
            newPuzzle()
        }
    }

    private func finish() {
        phase = .finished
        let elapsed = Date().timeIntervalSince(startedAt)
        treatsAwarded = treatsForTime(elapsed)
        guard !awarded else { return }
        awarded = true
        Rewards.awardTreats(treatsAwarded, in: modelContext)
    }

    private func treatsForTime(_ seconds: TimeInterval) -> Int {
        switch seconds {
        case ..<60:    return 3
        case 60..<120: return 2
        default:       return 1
        }
    }

    private func restart() {
        solvedCount = 0
        startedAt = .now
        phase = .playing
        awarded = false
        treatsAwarded = 0
        newPuzzle()
    }
}

#Preview {
    NavigationStack { WordScrambleGameView() }
        .modelContainer(
            for: [Avatar.self, Pet.self, FocusSession.self, Inventory.self, Decoration.self],
            inMemory: true
        )
}
