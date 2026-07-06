import Foundation
import CoreLocation

enum SessionStore {
    private static let key = "GameVerseSessions"

    static func all() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let sessions = try? JSONDecoder().decode([GameSession].self, from: data)
        else { return [] }
        return sessions
    }

    @discardableResult
    static func record(mode: GameMode, score: Int, coordinate: CLLocationCoordinate2D?) -> GameSession {
        var sessions = all()
        let session = GameSession(
            id: UUID(),
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: coordinate?.latitude,
            longitude: coordinate?.longitude
        )
        sessions.append(session)
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
        return session
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}