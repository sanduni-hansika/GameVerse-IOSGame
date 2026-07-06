import SwiftUI

@MainActor
final class QuizRushVM: ObservableObject {

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
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var progressFraction: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    func confirmName(_ name: String) {
        playerName = name
        roundState = .ready
    }

    func startGame() {
        statusMessage = nil
        viewState = .loading
        roundState = .playing
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
}