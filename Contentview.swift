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




    

    
}

#Preview {
    ContentView()
}