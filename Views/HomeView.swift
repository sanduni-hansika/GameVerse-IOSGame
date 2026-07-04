import SwiftUI

struct HomeView: View {

    @AppStorage("TapFrenzyHighScore") private var tapFrenzyHighScore: Int = 0
    @AppStorage("LightItUpHighScore") private var lightItUpHighScore: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 32) {
                        header

                        VStack(spacing: 18) {
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
                        }
                        .padding(.horizontal, 24)

                        footer
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
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
            Text("🎮")
                .font(.system(size: 44))

            Text("GameVerse")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Pick a mode and beat your best score")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var footer: some View {
        Text("BSc(Hons) Computing · iOS App Development · Week 2")
            .font(.caption)
            .foregroundColor(.white.opacity(0.3))
            .padding(.top, 12)
    }
}

#Preview {
    HomeView()
}
