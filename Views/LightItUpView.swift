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

private var readyView: some View {
        VStack(spacing: 22) {
            Text("💡 Light It Up")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("A card lights up — tap it before it goes dark.\nThe grid grows and the window shrinks as you go.")
                .font(.headline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            HStack(spacing: 10) {
                ForEach(GameLevel.allCases, id: \.self) { lvl in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(lvl.glowColor)
                            .frame(width: 12, height: 12)
                        Text(lvl.label)
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.top, 4)

            if highScore > 0 {
                Text("🏆 High Score: \(highScore)")
                    .font(.title3.bold())
                    .foregroundColor(.yellow)
                    .padding(.top, 6)
            }

            Button(action: startGame) {
                Text("Start Game")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: [.blue, .purple],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 14, y: 6)
            }
            .padding(.top, 10)
        }
        .padding()
    }






}

#Preview {
    NavigationStack { LightItUpView() }
}
