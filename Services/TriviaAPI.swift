import Foundation

enum TriviaAPIError: Error {
    case invalidURL
    case network
    case decoding
}

enum TriviaAPI {
    private static let endpoint = "https://opentdb.com/api.php?amount=10&type=multiple"

    static func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: endpoint) else { throw TriviaAPIError.invalidURL }

        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw TriviaAPIError.network
        }

        let decoded: TriviaResponse
        do {
            decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        } catch {
            throw TriviaAPIError.decoding
        }

        guard !decoded.results.isEmpty else { throw TriviaAPIError.decoding }

        return decoded.results.map { raw in
            let correct = raw.correctAnswer.htmlDecoded
            var answers = raw.incorrectAnswers.map { $0.htmlDecoded }
            answers.append(correct)
            answers.shuffle()
            return TriviaQuestion(
                question: raw.question.htmlDecoded,
                correctAnswer: correct,
                answers: answers
            )
        }
    }
}
