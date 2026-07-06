import SwiftUI

struct HomeTab: View {
    @State private var bestScores: [GameMode: Int] = [:]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 32) {
                        header

                        VStack(spacing: 18) {
                            GameModeCard(mode: .tapFrenzy, highScore: bestScores[.tapFrenzy] ?? 0) {
                                TapFrenzyView()
                            }
                            GameModeCard(mode: .lightItUp, highScore: bestScores[.lightItUp] ?? 0) {
                                LightItUpView()
                            }
                            GameModeCard(mode: .quizRush, highScore: bestScores[.quizRush] ?? 0) {
                                QuizRushView()
                            }
                        }
                        .padding(.horizontal, 24)

                        footer
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
            .onAppear { refreshBestScores() }
        }
    }

    private func refreshBestScores() {
        for mode in GameMode.allCases {
            bestScores[mode] = ScoreHistoryStore.topScores(for: mode.leaderboardKey).first?.score ?? 0
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.04, green: 0.04, blue: 0.13),
                     Color(red: 0.13, green: 0.05, blue: 0.24)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("🎮").font(.system(size: 44))
            Text("GameVerse")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text("Pick a mode and beat your best score")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var footer: some View {
        Text("Let's Play")
            .font(.caption)
            .foregroundColor(.white.opacity(0.3))
            .padding(.top, 12)
    }
}

#Preview {
    HomeTab()
}
