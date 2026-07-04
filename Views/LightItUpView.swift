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

 private var playingView: some View {
        VStack(spacing: 0) {
            hud

            Spacer()

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: level.columns),
                spacing: 14
            ) {
                ForEach(cards) { card in
                    LightCardView(isLit: card.isLit, glowColor: level.glowColor) {
                        handleTap(card)
                    }
                }
            }
            .padding(.horizontal, 28)
            .animation(.easeInOut(duration: 0.25), value: level)

            Spacer()
            Spacer()
        }
        .onAppear { setupRound() }
    }

    private var hud: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text("\(score)")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("LEVEL")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text(level.label)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(level.glowColor)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("TIME")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text(String(format: "%.0f", max(timeRemaining, 0)))
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(timeRemaining <= 8 ? .red : .white)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 24)
    }

private var gameOverView: some View {
        VStack(spacing: 18) {
            Text("⏱ Round Over!")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("\(score)")
                .font(.system(size: 68, weight: .black, design: .rounded))
                .foregroundColor(.blue)

            Text("Final Score")
                .font(.headline)
                .foregroundColor(.white.opacity(0.6))

            Text("Reached \(level.label)")
                .font(.subheadline.bold())
                .foregroundColor(level.glowColor)

            if isNewHighScore {
                Text("🎉 New High Score!")
                    .font(.title3.bold())
                    .foregroundColor(.yellow)
            } else {
                Text("🏆 High Score: \(highScore)")
                    .font(.title3.bold())
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 14) {
                Button(action: { dismiss() }) {
                    Text("Home")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                }

                Button(action: startGame) {
                    Text("Play Again")
                        .font(.headline.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().fill(
                                LinearGradient(colors: [.blue, .purple],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                        )
                        .shadow(color: .blue.opacity(0.5), radius: 14, y: 6)
                }
            }
            .padding(.top, 12)
        }
        .padding()
    }

 private func startGame() {
        score = 0
        timeRemaining = roundDuration
        level = .l1
        isNewHighScore = false
        resetCardsForCurrentLevel()
        gameState = .playing
    }

    private func setupRound() {
        stopTimers()
        startLightTimer()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            let elapsed = roundDuration - timeRemaining
            let newLevel = GameLevel.level(forElapsed: elapsed)

            if newLevel != level {
                level = newLevel
                resetCardsForCurrentLevel()
                startLightTimer()
                triggerLevelUpFlash()
            }

            if timeRemaining <= 0 {
                timeRemaining = 0
                endGame()
            }
        }
    }

 /// (Re)builds the grid for the current level, all cards starting dim.
    private func resetCardsForCurrentLevel() {
        cards = (0..<level.cardCount).map { Card(id: $0, isLit: false) }
    }

    /// Restarts the lighting timer at the current level's interval.
    private func startLightTimer() {
        lightTimer?.invalidate()
        lightTimer = Timer.scheduledTimer(withTimeInterval: level.litWindow, repeats: true) { _ in
            tick()
        }
    }

    /// Fires every `level.litWindow` seconds: penalizes missed cards,
    /// then lights a fresh random set.
    private func tick() {
        guard gameState == .playing else { return }

        let missedCount = cards.filter { $0.isLit }.count
        for _ in 0..<missedCount {
            applyPenalty()
        }

        for i in cards.indices {
            cards[i].isLit = false
        }

        let count = min(level.simultaneousLit, cards.count)
        let indicesToLight = Array(cards.indices.shuffled().prefix(count))

        withAnimation(.easeInOut(duration: 0.2)) {
            for i in indicesToLight {
                cards[i].isLit = true
            }
        }
    }

private func handleTap(_ card: Card) {
        guard gameState == .playing else { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isLit {
            score += 1
            withAnimation(.easeOut(duration: 0.15)) {
                cards[index].isLit = false
            }
        } else {
            applyPenalty()
        }
    }

    private func applyPenalty() {
        score = max(0, score - 1)
    }

    private func triggerLevelUpFlash() {
        withAnimation(.easeIn(duration: 0.15)) { showLevelUpFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) { showLevelUpFlash = false }
        }
    }






}

#Preview {
    NavigationStack { LightItUpView() }
}
