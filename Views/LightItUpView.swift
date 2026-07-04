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

   







   
}

#Preview {
    NavigationStack { LightItUpView() }
}
