import Foundation

@MainActor
final class StatsVM: ObservableObject {
    @Published var sessions: [GameSession] = []

    func refresh() {
        sessions = SessionStore.all().sorted { $0.timestamp > $1.timestamp }
    }

    var totalGamesPlayed: Int { sessions.count }

    var totalScore: Int { sessions.reduce(0) { $0 + $1.score } }

    func personalBest(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    func gamesPlayed(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }

    var recentSessions: [GameSession] {
        Array(sessions.prefix(10))
    }

    func chartSessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }.sorted { $0.timestamp < $1.timestamp }
    }

    var sessionsWithLocation: [GameSession] {
        sessions.filter { $0.coordinate != nil }
    }
}
