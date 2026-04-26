import SwiftUI

struct GameMenuView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        header
                        ForEach(MiniGameRegistry.all) { game in
                            NavigationLink {
                                game.view()
                            } label: {
                                gameCard(for: game)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer(minLength: 16)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Break Time")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Earn treats for your pet")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.accent)
            Text("Finish a mini-game to give your buddy a snack.")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.accent.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func gameCard(for game: AnyMiniGame) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.primary)
                Image(systemName: game.symbol)
                    .font(.system(size: 28))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(Theme.Font.title)
                    .foregroundStyle(Theme.accent)
                Text(game.summary)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.accent.opacity(0.7))
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.accent.opacity(0.6))
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    GameMenuView()
}
