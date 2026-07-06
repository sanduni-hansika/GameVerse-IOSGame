import Foundation

struct TriviaQuestionRaw: Codable {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
struct TriviaResponse: Codable {
    let results: [TriviaQuestionRaw]
}

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let question: String
    let correctAnswer: String
    let answers: [String]
}