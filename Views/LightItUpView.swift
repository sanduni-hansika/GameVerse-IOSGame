import SwiftUI

struct LightItUpView: View {

    @Environment(\.dismiss) private var dismiss

    private let roundDuration: Double = 60.0

    @State private var gameState: GameRoundState = .ready
    @State private var score: Int = 0
    @State private var timeRemaining: Double = 60.0
    @State private var level: GameLevel = .l1
    @AppStorage("LightItUpHighScore") private var highScore: Int = 0
    @State private var isNewHighScore: Bool = false

    @State private var cards: [Card] = []
    @State private var showLevelUpFlash: Bool = false

    @State private var countdownTimer: Timer? = nil
    @State private var lightTimer: Timer? = nil

    var body: some View {
        ZStack {
            backgroundGradient

            switch gameState {
            case .ready:
                readyView
            case .playing:
                playingView
            case .gameOver:
                gameOverView
            }

            if showLevelUpFlash {
                levelUpFlash
            }

            backButton
        }
        .navigationBarHidden(true)
        .onDisappear { stopTimers() }
    }

   private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.04, green: 0.05, blue: 0.14),
                     Color(red: 0.08, green: 0.05, blue: 0.24)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var backButton: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                .padding(.leading, 16)
                .padding(.top, 12)
                Spacer()
            }
            Spacer()
        }
    }

    private var levelUpFlash: some View {
        ZStack {
            level.glowColor.opacity(0.22).ignoresSafeArea()
            Text("LEVEL \(level.rawValue)")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: level.glowColor, radius: 20)
        }
        .transition(.opacity)
        .allowsHitTesting(false)
    } 








}

#Preview {
    NavigationStack { LightItUpView() }
}
