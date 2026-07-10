import SwiftUI
import CoreLocation

@MainActor
final class LightItUpVM: ObservableObject {

    let roundDuration: Double = 60.0

    @Published var roundState: GameRoundState = .nameEntry
    @Published var playerName: String = ""
    @Published var score: Int = 0
    @Published var timeRemaining: Double = 60.0
    @Published var level: GameLevel = .l1
    @Published var cards: [Card] = []
    @Published var showLevelUpFlash: Bool = false

    @Published var scores: [PlayerScore] = []
    @Published var lastEntryID: UUID?
    @Published var statusMessage: String?

    private var countdownTimer: Timer?
    private var lightTimer: Timer?

    func loadLeaderboard() {
        scores = ScoreHistoryStore.topScores(for: GameMode.lightItUp.leaderboardKey)
    }

    func confirmName(_ name: String) {
        playerName = name
        roundState = .ready
    }

    func startGame() {
        score = 0
        timeRemaining = roundDuration
        level = .l1
        statusMessage = nil
        resetCardsForCurrentLevel()
        roundState = .playing
    }

    func setupRound() {
        stopTimers()
        startLightTimer()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickCountdown() }
        }
    }

    private func tickCountdown() {
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

    private func resetCardsForCurrentLevel() {
        cards = (0..<level.cardCount).map { Card(id: $0, isLit: false) }
    }

    private func startLightTimer() {
        lightTimer?.invalidate()
        lightTimer = Timer.scheduledTimer(withTimeInterval: level.litWindow, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        guard roundState == .playing else { return }

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

    func handleTap(_ card: Card) {
        guard roundState == .playing else { return }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) { self?.showLevelUpFlash = false }
        }
    }

    private func endGame() {
        stopTimers()

        let coordinate = LocationService.shared.currentLocation
        SessionStore.record(mode: .lightItUp, score: score, coordinate: coordinate)

        let (top, entryID) = ScoreHistoryStore.submit(
            playerName: playerName, score: score, key: GameMode.lightItUp.leaderboardKey
        )
        scores = top
        lastEntryID = entryID
        statusMessage = (top.first?.id == entryID) ? "🏆 New personal best" :
            (top.contains { $0.id == entryID } ? "Made the top 5" : nil)

        roundState = .gameOver
    }

    func stopTimers() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        lightTimer?.invalidate()
        lightTimer = nil
    }
}