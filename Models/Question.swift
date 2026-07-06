import Foundation

struct Question: Codable, Identifiable {
    var id: String { question }
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
struct QuestionsResponse: Codable {
    let results: [Question]
}