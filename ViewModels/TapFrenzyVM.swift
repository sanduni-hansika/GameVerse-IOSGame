import SwiftUI
import CoreLocation

struct ScorePopup: Identifiable {
    let id = UUID()
    var position: CGPoint
    var opacity: Double = 1.0
    var offsetY: CGFloat = 0
}

@MainActor
final class TapFrenzyVM: ObservableObject {

    let gameDuration: Double = 10.0
    private let buttonBaseSize: CGFloat = 140
    private let buttonMinSize: CGFloat = 60
    private let moveInterval: Double = 2.0

    @Published var roundState: GameRoundState = .nameEntry
    @Published var playerName: String = ""
    @Published var score: Int = 0
    @Published var timeRemaining: Double = 10.0
    @Published var buttonOffset: CGSize = .zero
    @Published var buttonSize: CGFloat = 140
    @Published var popups: [ScorePopup] = []
    @Published var isPressed: Bool = false

    @Published var scores: [PlayerScore] = []
    @Published var lastEntryID: UUID?
    @Published var statusMessage: String?

    private var countdownTimer: Timer?
    private var moveTimer: Timer?

    func loadLeaderboard() {
        scores = ScoreHistoryStore.topScores(for: GameMode.tapFrenzy.leaderboardKey)
    }

    func confirmName(_ name: String) {
        playerName = name
        roundState = .ready
    }

    func startGame() {
        score = 0
        timeRemaining = gameDuration
        buttonSize = buttonBaseSize
        buttonOffset = .zero
        popups.removeAll()
        statusMessage = nil
        roundState = .playing
    }

    func setupRound(in geo: GeometryProxy) {
        stopTimers()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickCountdown() }
        }

        moveTimer = Timer.scheduledTimer(withTimeInterval: moveInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.randomizeButtonPosition(in: geo) }
        }
    }

    private func tickCountdown() {
        timeRemaining -= 0.1
        buttonSize = sizeForTimeRemaining()
        if timeRemaining <= 0 {
            timeRemaining = 0
            endGame()
        }
    }

    private func sizeForTimeRemaining() -> CGFloat {
        let ratio = max(timeRemaining / gameDuration, 0)
        return buttonMinSize + (buttonBaseSize - buttonMinSize) * CGFloat(ratio)
    }

    private func randomizeButtonPosition(in geo: GeometryProxy) {
        let halfSize = buttonSize / 2
        let topInset: CGFloat = 140
        let bottomInset: CGFloat = 60
        let sideInset: CGFloat = 20

        let minX = sideInset + halfSize
        let maxX = geo.size.width - sideInset - halfSize
        let minY = topInset + halfSize
        let maxY = geo.size.height - bottomInset - halfSize

        guard maxX > minX, maxY > minY else { return }

        let newX = CGFloat.random(in: minX...maxX)
        let newY = CGFloat.random(in: minY...maxY)
        let centerX = geo.size.width / 2
        let centerY = geo.size.height / 2

        buttonOffset = CGSize(width: newX - centerX, height: newY - centerY)
    }

    func handleTap() {
        guard roundState == .playing else { return }
        score += 1

        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isPressed = false
        }

        spawnScorePopup()
    }

    private func spawnScorePopup() {
        let screenSize = UIScreen.main.bounds.size
        let centerX = screenSize.width / 2 + buttonOffset.width
        let centerY = screenSize.height / 2 + buttonOffset.height - (buttonSize / 2) - 20

        let popup = ScorePopup(position: CGPoint(x: centerX, y: centerY))
        popups.append(popup)

        withAnimation(.easeOut(duration: 0.6)) {
            if let index = popups.firstIndex(where: { $0.id == popup.id }) {
                popups[index].offsetY = -50
                popups[index].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.popups.removeAll { $0.id == popup.id }
        }
    }

    private func endGame() {
        stopTimers()

        let coordinate = LocationService.shared.currentLocation
        SessionStore.record(mode: .tapFrenzy, score: score, coordinate: coordinate)

        let (top, entryID) = ScoreHistoryStore.submit(
            playerName: playerName, score: score, key: GameMode.tapFrenzy.leaderboardKey
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
        moveTimer?.invalidate()
        moveTimer = nil
    }
}