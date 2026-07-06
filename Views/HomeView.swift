import SwiftUI

struct HomeView: View {

    @State private var tapFrenzyBest: Int = ScoreHistoryStore.bestScore(for: "TapFrenzyHistory")
    @State private var lightItUpBest: Int = ScoreHistoryStore.bestScore(for: "LightItUpHistory")
    @State private var quizRushBest: Int = ScoreHistoryStore.bestScore(for: "QuizRushHistory")

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 32) {
                        header

                        VStack(spacing: 16) {
                            GameModeCard(
                                title: "Tap Frenzy",
                                subtitle: "Tap as fast as you can before the 10s clock runs out.",
                                systemImage: "bolt.fill",
                                colors: [.orange, .pink],
                                highScore: tapFrenzyHighScore
                            ) {
                                TapFrenzyView()
                            }

                            GameModeCard(
                                title: "Light It Up",
                                subtitle: "Cards flash — tap the lit one before it goes dark.",
                                systemImage: "square.grid.3x3.fill",
                                colors: [.blue, .purple],
                                highScore: lightItUpHighScore
                            ) {
                                LightItUpView()
                            }

                        GameModeCard(
                                title: "Quiz Rush",
                                subtitle: "10 live trivia questions. Build a streak for bonus points.",
                                systemImage: "questionmark.circle.fill",
                                colors: [.orange, .red],
                                highScore: quizRushBest
                            ) {
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
            .onAppear(perform: refreshScores)
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
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                    .shadow(color: .pink.opacity(0.4), radius: 12, y: 4)

                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("GameVerse")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Pick a mode and beat your best score")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var footer: some View {
        Text("Let's play")
            .font(.caption)
            .foregroundColor(.white.opacity(0.3))
            .padding(.top, 12)
    }

    private func refreshScores() {
        tapFrenzyBest = ScoreHistoryStore.bestScore(for: "TapFrenzyHistory")
        lightItUpBest = ScoreHistoryStore.bestScore(for: "LightItUpHistory")
        quizRushBest = ScoreHistoryStore.bestScore(for: "QuizRushHistory")
    }

}

#Preview {
    HomeView()
}
