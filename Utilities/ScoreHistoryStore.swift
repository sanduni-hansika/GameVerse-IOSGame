import Foundation

enum ScoreHistoryStore {

    static func load(for key: String) -> [PlayerScore] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let scores = try? JSONDecoder().decode([PlayerScore].self, from: data) else {
            return []
        }
        return scores
    }

    @discardableResult
    static func record(_ score: Int, playerName: String, for key: String) -> (top5: [PlayerScore], entryID: UUID) {
        var scores = load(for: key)
        let entry = PlayerScore(id: UUID(), playerName: playerName, score: score, date: Date())
        scores.append(entry)
        scores.sort { $0.score > $1.score }
        let top5 = Array(scores.prefix(5))

        if let data = try? JSONEncoder().encode(top5) {
            UserDefaults.standard.set(data, forKey: key)
        }
        return (top5, entry.id)
    }

    static func bestScore(for key: String) -> Int {
        load(for: key).first?.score ?? 0
    }
}
