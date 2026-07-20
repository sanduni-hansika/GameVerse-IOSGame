import SwiftUI

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }

    var systemImage: String {
        switch self {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "square.grid.3x3.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }

    var colors: [Color] {
        switch self {
        case .tapFrenzy: return [.orange, .pink]
        case .lightItUp: return [.blue, .purple]
        case .quizRush: return [.orange, .red]
        }
    }

    var leaderboardKey: String {
        switch self {
        case .tapFrenzy: return "TapFrenzyLeaderboard"
        case .lightItUp: return "LightItUpLeaderboard"
        case .quizRush: return "QuizRushLeaderboard"
        }
    }
}