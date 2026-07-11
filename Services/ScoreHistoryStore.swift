import Foundation

enum ScoreHistoryStore {
    static func topScores(for key: String) -> [PlayerScore] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let scores = try? JSONDecoder().decode([PlayerScore].self, from: data)
        else { return [] }
        return scores
    }

    @discardableResult
    static func submit(playerName: String, score: Int, key: String) -> (top: [PlayerScore], entryID: UUID) {
        var scores = topScores(for: key)
        let entry = PlayerScore(id: UUID(), playerName: playerName, score: score, date: Date())
        scores.append(entry)
        scores.sort { $0.score > $1.score }
        let top5 = Array(scores.prefix(5))
        if let data = try? JSONEncoder().encode(top5) {
            UserDefaults.standard.set(data, forKey: key)
        }
        return (top5, entry.id)
    }

    static func resetAll() {
        for mode in GameMode.allCases {
            UserDefaults.standard.removeObject(forKey: mode.leaderboardKey)
        }
    }
}
