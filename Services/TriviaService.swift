import Foundation

enum TriviaServiceError: Error {
    case badResponse
    case decodingFailed
}

enum TriviaService {
    private static let endpoint = "https://opentdb.com/api.php?amount=10&type=multiple"

    static func fetchQuestions() async throws -> [Question] {
        guard let url = URL(string: endpoint) else {
            throw TriviaServiceError.badResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TriviaServiceError.badResponse
        }

        do {
            let decoded = try JSONDecoder().decode(QuestionsResponse.self, from: data)
            return decoded.results
        } catch {
            throw TriviaServiceError.decodingFailed
        }
    }
}
