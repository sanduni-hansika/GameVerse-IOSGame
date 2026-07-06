import SwiftUI

struct LightItUpView: View {

    @Environment(\.dismiss) private var dismiss

    private static let historyKey = "LightItUpHistory"
    private let accentColors: [Color] = [.blue, .purple]


    private let roundDuration: Double = 60.0

    @State private var gameState: GameRoundState = .nameEntry
    @State private var playerName: String = ""
    @State private var score: Int = 0
    @State private var timeRemaining: Double = 60.0
    @State private var level: GameLevel = .l1

    @State private var scoreHistory: [PlayerScore] = ScoreHistoryStore.load(for: LightItUpView.historyKey)
    @State private var lastEntryID: UUID? = nil

    @State private var cards: [Card] = []
    @State private var showLevelUpFlash: Bool = false
    @State private var popups: [ScorePopup] = []

    @State private var countdownTimer: Timer? = nil
    @State private var lightTimer: Timer? = nil

    private var trimmedName: String {
        playerName.trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        ZStack {
            backgroundGradient

            backgroundGradient

            switch gameState {
            case .nameEntry:
                nameEntryView
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

 private var nameEntryView: some View {
        VStack(spacing: 26) {
            GameTitleBadge(systemImage: "square.grid.3x3.fill", title: "Light It Up", colors: accentColors)

            Text("Enter your name to start the round.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))

            PlayerNameField(name: $playerName, accentColors: accentColors)
                .padding(.horizontal, 36)

            Button(action: { gameState = .ready }) {
                Text("Continue")
                    .font(.headline.bold())
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(
                        Capsule().fill(
                            trimmedName.isEmpty
                                ? AnyShapeStyle(Color.white.opacity(0.15))
                                : AnyShapeStyle(LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing))
                        )
                    )
                    .foregroundColor(trimmedName.isEmpty ? .white.opacity(0.4) : .black)
            }
            .disabled(trimmedName.isEmpty)
        }
        .padding()
    }

private var readyView: some View {
        ScrollView {
            VStack(spacing: 22) {
                GameTitleBadge(systemImage: "square.grid.3x3.fill", title: "Light It Up", colors: accentColors)

            Text("A card lights up — tap it before it goes dark.\nThe grid grows and the window shrinks as you go.")
                .font(.headline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            HStack(spacing: 16) {
                ForEach(GameLevel.allCases, id: \.self) { lvl in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(lvl.glowColor)
                            .frame(width: 10, height: 10)
                        Text(lvl.label)
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.55))
                          }
                    }
                }
             playerBadge

                Button(action: startGame) {
                    Text("Start Game")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 16)
                        .background(
                            Capsule().fill(LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: accentColors[0].opacity(0.5), radius: 14, y: 6)
                }

                ScoreHistoryView(
                    title: "TOP SCORES",
                    scores: scoreHistory,
                    accentColor: accentColors[0]
                )
                .padding(.horizontal, 28)
                .padding(.top, 6)
            }
            .padding(.vertical, 24)
        }
    }

    private var playerBadge: some View {
        HStack(spacing: 6) {
            Text("Playing as")
                .foregroundColor(.white.opacity(0.5))
            Text(trimmedName)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            Button("Change") { gameState = .nameEntry }
                .font(.caption.bold())
                .foregroundColor(.blue)
        }
        .font(.footnote)
    }
 private var playingView: some View {
    ZStack {
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

ForEach(popups) { popup in
                Text(popup.label)
                    .font(.title2.bold())
                    .foregroundColor(popup.color)
                    .shadow(color: .black.opacity(0.4), radius: 3)
                    .position(x: popup.position.x, y: popup.position.y + popup.offsetY)
                    .opacity(popup.opacity)
            }
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
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.white.opacity(0.6))
                    Text("Round Over")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)

                Text("\(score)")
                    .font(.system(size: 68, weight: .black, design: .rounded))
                    .foregroundColor(.blue)

                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))

                Text("Reached \(level.label)")
                    .font(.subheadline.bold())
                    .foregroundColor(level.glowColor)

                leaderboardBadge

                HStack(spacing: 14) {
                    Button(action: { dismiss() }) {
                        Text("Home")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1.5))
                    }

                    Button(action: startGame) {
                        Text("Play Again")
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing))
                            )
                            .shadow(color: accentColors[0].opacity(0.5), radius: 14, y: 6)
                    }
                }
                .padding(.top, 4)

                ScoreHistoryView(
                    title: "TOP SCORES",
                    scores: scoreHistory,
                    highlightID: lastEntryID,
                    accentColor: accentColors[0]
                )
                .padding(.horizontal, 28)
                .padding(.top, 10)
            }
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private var leaderboardBadge: some View {
        if lastEntryID != nil {
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill").foregroundColor(.yellow)
                Text(scoreHistory.first?.id == lastEntryID ? "New personal best" : "Made the top 5")
                    .foregroundColor(.yellow)
            }
            .font(.subheadline.bold())
        }
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

    private func resetCardsForCurrentLevel() {
        cards = (0..<level.cardCount).map { Card(id: $0, isLit: false) }
    }

    private func startLightTimer() {
        lightTimer?.invalidate()
        lightTimer = Timer.scheduledTimer(withTimeInterval: level.litWindow, repeats: true) { _ in
            tick()
        }
    }

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

    private func spawnScorePopup(correct: Bool) {
        let screenSize = UIScreen.main.bounds.size
        var popup = ScorePopup(position: CGPoint(x: screenSize.width / 2, y: screenSize.height * 0.42))
        popup.label = correct ? "+1" : "-1"
        popup.color = correct ? .green : .red
        popups.append(popup)

        withAnimation(.easeOut(duration: 0.6)) {
            if let index = popups.firstIndex(where: { $0.id == popup.id }) {
                popups[index].offsetY = -40
                popups[index].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            popups.removeAll { $0.id == popup.id }
        }
    }

    private func triggerLevelUpFlash() {
        withAnimation(.easeIn(duration: 0.15)) { showLevelUpFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) { showLevelUpFlash = false }
        }
    }

private func endGame() {
        stopTimers()
        let name = trimmedName.isEmpty ? "Player" : trimmedName
        let result = ScoreHistoryStore.record(score, playerName: name, for: Self.historyKey)
        scoreHistory = result.top5
        lastEntryID = result.top5.contains(where: { $0.id == result.entryID }) ? result.entryID : nil
        gameState = .gameOver
    }

    private func stopTimers() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        lightTimer?.invalidate()
        lightTimer = nil
    }


}

#Preview {
    NavigationStack { LightItUpView() }
}
