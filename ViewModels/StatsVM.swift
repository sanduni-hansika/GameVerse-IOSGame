import Foundation
import CoreLocation
internal import Combine

@MainActor
final class StatsVM: ObservableObject {

    @Published var sessions: [GameSession] = []


    init() {
        refresh()
    }


    func refresh() {

        sessions = SessionStore.all()
            .sorted {
                $0.timestamp > $1.timestamp
            }
    }

    var totalGamesPlayed: Int {
        sessions.count
    }


    var totalScore: Int {

        sessions.reduce(0) { result, session in
            result + session.score
        }
    }


    func personalBest(for mode: GameMode) -> Int {

        sessions
            .filter {
                $0.mode == mode
            }
            .map {
                $0.score
            }
            .max() ?? 0
    }


    func gamesPlayed(for mode: GameMode) -> Int {

        sessions
            .filter {
                $0.mode == mode
            }
            .count
    }


    var recentSessions: [GameSession] {

        Array(
            sessions.prefix(10)
        )
    }


    func chartSessions(for mode: GameMode) -> [GameSession] {

        sessions
            .filter {
                $0.mode == mode
            }
            .sorted {
                $0.timestamp < $1.timestamp
            }
    }


    var sessionsWithLocation: [GameSession] {

        sessions.filter {
            $0.coordinate != nil
        }
    }



    func saveGame(
        mode: GameMode,
        score: Int
    ) {

        guard let location = LocationService.shared.currentLocation else {

            print("No GPS location available")
            return
        }


        SessionStore.record(
            mode: mode,
            score: score,
            coordinate: location
        )


        refresh()


        print(
            """
            GAME SAVED

            Latitude:
            \(location.latitude)

            Longitude:
            \(location.longitude)
            """
        )
    }
}
