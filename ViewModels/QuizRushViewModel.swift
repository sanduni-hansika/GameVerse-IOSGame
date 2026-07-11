import SwiftUI
import CoreLocation
internal import Combine

@MainActor
final class QuizRushVM: ObservableObject {

    private let pointsPerCorrect = 10
    private let streakBonusEvery = 3
    private let streakBonusPoints = 5
    private let wrongPenalty = 5


    @Published var roundState: GameRoundState = .nameEntry
    @Published var playerName: String = ""

    @Published var viewState: QuizViewState = .loading
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0

    @Published var selectedAnswer: String?
    @Published var answerState: AnswerState = .none
    @Published var lastPointsEarned: Int = 0

    @Published var scores: [PlayerScore] = []
    @Published var lastEntryID: UUID?
    @Published var statusMessage: String?


    var currentQuestion: TriviaQuestion? {
        questions.indices.contains(currentIndex)
        ? questions[currentIndex]
        : nil
    }


    var progressFraction: Double {
        guard !questions.isEmpty else {
            return 0
        }

        return Double(currentIndex) / Double(questions.count)
    }


    func loadLeaderboard() {

        scores = ScoreHistoryStore.topScores(
            for: GameMode.quizRush.leaderboardKey
        )
    }


    func confirmName(_ name: String) {

        print("Quiz name confirmed:", name)

        playerName = name
        roundState = .ready
    }


    func startGame() {

        statusMessage = nil
        viewState = .loading
        roundState = .playing
    }


    func load() async {

        viewState = .loading

        do {

            let fetched =
            try await TriviaAPI.fetchQuestions()

            questions = fetched
            currentIndex = 0
            score = 0
            streak = 0
            selectedAnswer = nil
            answerState = .none

            viewState = .loaded

        } catch {

            viewState = .failed
        }
    }


    @discardableResult
    func submit(_ answer: String) -> Int {

        guard answerState == .none,
              let question = currentQuestion else {
            return 0
        }


        selectedAnswer = answer


        if answer == question.correctAnswer {

            streak += 1

            var gained = pointsPerCorrect


            if streak % streakBonusEvery == 0 {
                gained += streakBonusPoints
            }


            score += gained
            answerState = .correct
            lastPointsEarned = gained

            return gained


        } else {

            streak = 0

            score = max(
                0,
                score - wrongPenalty
            )

            answerState = .wrong
            lastPointsEarned = -wrongPenalty

            return -wrongPenalty
        }
    }


    func advance() {

        selectedAnswer = nil
        answerState = .none


        if currentIndex + 1 < questions.count {

            currentIndex += 1

        } else {

            endGame()
        }
    }


    private func endGame() {

        let coordinate =
        LocationService.shared.currentLocation


        SessionStore.record(
            mode: .quizRush,
            score: score,
            coordinate: coordinate
        )


        let (top, entryID) =
        ScoreHistoryStore.submit(
            playerName: playerName,
            score: score,
            key: GameMode.quizRush.leaderboardKey
        )


        scores = top
        lastEntryID = entryID


        statusMessage =
        (top.first?.id == entryID)
        ? "🏆 New personal best"
        : (
            top.contains {
                $0.id == entryID
            }
            ? "Made the top 5"
            : nil
        )


        roundState = .gameOver
    }
}
