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