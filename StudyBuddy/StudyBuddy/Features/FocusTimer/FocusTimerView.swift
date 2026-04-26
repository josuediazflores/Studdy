import SwiftUI
import SwiftData

struct FocusTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var model = FocusTimerModel()
    @State private var selectedMinutes: Int = 25
    @State private var customGoal: String = ""

    private let presets: [Int] = [15, 25, 45]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 28) {
                    Text("Focus Time")
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.accent)

                    timerRing

                    presetChips

                    customGoalField

                    controlButtons

                    Spacer(minLength: 0)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Theme.surface, lineWidth: 18)
            Circle()
                .trim(from: 0, to: model.progress)
                .stroke(Theme.primary, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.25), value: model.progress)

            VStack(spacing: 4) {
                Text(formatted(model.remainingSeconds))
                    .font(Theme.Font.timer)
                    .foregroundStyle(Theme.accent)
                    .monospacedDigit()
                Text(model.isRunning ? "Studying" : "Ready")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.accent.opacity(0.7))
            }
        }
        .frame(width: 260, height: 260)
    }

    private var presetChips: some View {
        HStack(spacing: 12) {
            ForEach(presets, id: \.self) { minutes in
                Button(action: { applyPreset(minutes) }) {
                    Text("\(minutes) min")
                        .font(Theme.Font.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(selectedMinutes == minutes ? Theme.primary : Theme.surface)
                        .foregroundStyle(selectedMinutes == minutes ? Color.white : Theme.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(model.isRunning)
            }
        }
    }

    private var customGoalField: some View {
        HStack {
            Image(systemName: "target")
                .foregroundStyle(Theme.accent)
            TextField("Set your own goal (e.g. read chapter 3)", text: $customGoal)
                .font(Theme.Font.body)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: toggle) {
                Label(model.isRunning ? "Pause" : "Start",
                      systemImage: model.isRunning ? "pause.fill" : "play.fill")
                    .font(Theme.Font.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.primary)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            Button(action: { model.reset() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(Theme.Font.title)
                    .padding(14)
                    .background(Theme.surface)
                    .foregroundStyle(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }

    private func applyPreset(_ minutes: Int) {
        selectedMinutes = minutes
        model.totalSeconds = minutes * 60
        model.remainingSeconds = minutes * 60
    }

    private func toggle() {
        if model.isRunning {
            model.pause()
        } else if model.remainingSeconds < model.totalSeconds && model.remainingSeconds > 0 {
            model.resume(context: modelContext)
        } else {
            model.start(minutes: selectedMinutes, context: modelContext)
        }
    }

    private func formatted(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    FocusTimerView()
        .modelContainer(
            for: [Avatar.self, Pet.self, FocusSession.self, Inventory.self, Decoration.self],
            inMemory: true
        )
}
