import Foundation

@MainActor
final class QuizRushViewModel: ObservableObject {

    @Published private(set) var state: QuizViewState = .loading
    @Published private(set) var questions: [Question] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var answerOptions: [String] = []
    @Published private(set) var selectedAnswer: String? = nil
    @Published private(set) var isAnswerLocked: Bool = false
    @Published private(set) var lastPointsEarned: Int = 0

    private let correctPoints = 10
    private let wrongPenalty = 5
    private let maxStreakBonus = 5

    var currentQuestion: Question? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var totalQuestions: Int { questions.count }

    var isLastQuestion: Bool {
        currentIndex >= questions.count - 1
    }

    func load() async {
        state = .loading
        do {
            let fetched = try await TriviaService.fetchQuestions()
            questions = fetched
            currentIndex = 0
            score = 0
            streak = 0
            prepareOptions()
            state = .loaded
        } catch {
            state = .failed
        }
    }

    private func prepareOptions() {
        guard let question = currentQuestion else { return }
        var options = question.incorrectAnswers.map { $0.htmlDecoded }
        options.append(question.correctAnswer.htmlDecoded)
        answerOptions = options.shuffled()
        selectedAnswer = nil
        isAnswerLocked = false
    }
    func selectAnswer(_ answer: String) {
        guard !isAnswerLocked, let question = currentQuestion else { return }
        selectedAnswer = answer
        isAnswerLocked = true

        if answer == question.correctAnswer.htmlDecoded {
            streak += 1
            let bonus = min(streak - 1, maxStreakBonus)
            let points = correctPoints + bonus
            lastPointsEarned = points
            score += points
        } else {
            streak = 0
            lastPointsEarned = -wrongPenalty
            score = max(0, score - wrongPenalty)
        }
    }

    func advance() {
        currentIndex += 1
        prepareOptions()
    }
}
