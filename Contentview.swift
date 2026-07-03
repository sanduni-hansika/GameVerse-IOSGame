import SwiftUI

enum GameState {
    case ready
    case playing
    case gameOver
}

struct ScorePopup: Identifiable {
    let id = UUID()
    var position: CGPoint
    var opacity: Double = 1.0
    var offsetY: CGFloat = 0
}

struct ContentView: View {

    private let gameDuration: Double = 10.0
    private let buttonBaseSize: CGFloat = 140
    private let buttonMinSize: CGFloat = 60
    private let moveInterval: Double = 2.0


    @State private var gameState: GameState = .ready
    @State private var score: Int = 0
    @State private var timeRemaining: Double = 10.0
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "TapFrenzyHighScore")
    @State private var isNewHighScore: Bool = false

    @State private var buttonOffset: CGSize = .zero
    @State private var buttonSize: CGFloat = 140

    @State private var popups: [ScorePopup] = []

    @State private var countdownTimer: Timer? = nil
    @State private var moveTimer: Timer? = nil

    @State private var isPressed: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient

                switch gameState {
                case .ready:
                    readyView
                case .playing:
                    playingView(in: geo)
                case .gameOver:
                    gameOverView
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.05, blue: 0.15),
                     Color(red: 0.14, green: 0.05, blue: 0.26)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

private var readyView: some View {
        VStack(spacing: 22) {
            Text("⚡️ Tap Frenzy")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
 
            Text("Tap as many times as you can in \(Int(gameDuration)) seconds!")
                .font(.headline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
 
            VStack(alignment: .leading, spacing: 10) {
                Label("Button shrinks as time runs out", systemImage: "arrow.down.right.and.arrow.up.left.circle.fill")
                Label("Button jumps to a new spot every 2s", systemImage: "arrow.left.arrow.right.circle.fill")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white.opacity(0.65))
            .padding(.top, 4)
 
            if highScore > 0 {
                Text("🏆 High Score: \(highScore)")
                    .font(.title3.bold())
                    .foregroundColor(.yellow)
                    .padding(.top, 10)
            }
 
            Button(action: startGame) {
                Text("Start Game")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: [.green, .mint],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                    )
                    .shadow(color: .green.opacity(0.5), radius: 14, y: 6)
            }
            .padding(.top, 14)
        }
        .padding()
    }
 
private func playingView(in geo: GeometryProxy) -> some View {
        ZStack {
            VStack {
                hud
                Spacer()
            }
 
            tapButton
                .offset(buttonOffset)
                .animation(.spring(response: 0.45, dampingFraction: 0.65), value: buttonOffset)
                .animation(.easeInOut(duration: 0.25), value: buttonSize)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
 
            
            ForEach(popups) { popup in
                Text("+1")
                    .font(.title.bold())
                    .foregroundColor(.green)
                    .shadow(color: .black.opacity(0.4), radius: 3)
                    .position(x: popup.position.x, y: popup.position.y + popup.offsetY)
                    .opacity(popup.opacity)
            }
        }
        .onAppear { setupRound(in: geo) }
        .onDisappear { stopTimers() }
    }
 
    private var hud: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text("\(score)")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("TIME")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text(String(format: "%.1f", max(timeRemaining, 0)))
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(timeRemaining <= 3 ? .red : .white)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

private var tapButton: some View {
        Button(action: handleTap) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange, Color.pink],
                            center: .center, startRadius: 5, endRadius: buttonSize
                        )
                    )
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(color: .pink.opacity(0.6), radius: 16, y: 8)
 
                Text("TAP")
                    .font(.system(size: max(14, buttonSize * 0.18), weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.88 : 1.0)
        }
        .buttonStyle(.plain)
    }

private var gameOverView: some View {
        VStack(spacing: 18) {
            Text("⏱ Time's Up!")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
 
            Text("\(score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundColor(.green)
 
            Text("Final Score")
                .font(.headline)
                .foregroundColor(.white.opacity(0.6))
 
            if isNewHighScore {
                Text("🎉 New High Score!")
                    .font(.title3.bold())
                    .foregroundColor(.yellow)
            } else {
                Text("🏆 High Score: \(highScore)")
                    .font(.title3.bold())
                    .foregroundColor(.white.opacity(0.7))
            }
 
            Button(action: startGame) {
                Text("Play Again")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: [.green, .mint],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                    )
                    .shadow(color: .green.opacity(0.5), radius: 14, y: 6)
            }
            .padding(.top, 12)
        }
        .padding()
    }




    
}

#Preview {
    ContentView()
}