import SwiftUI

enum GameLevel: Int, CaseIterable {
    case l1 = 1
    case l2 = 2
    case l3 = 3
    case l4 = 4

    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 2
        case .l3: return 3
        case .l4: return 3
        }
    }

    var litWindow: Double {
        switch self {
        case .l1: return 1.3
        case .l2: return 1.2
        case .l3: return 0.9
        case .l4: return 0.8
        }
    }

    var simultaneousLit: Int {
        self == .l4 ? 2 : 1
    }

    var glowColor: Color {
        switch self {
        case .l1: return .green
        case .l2: return .blue
        case .l3: return .yellow
        case .l4: return .red
        }
    }

    var label: String { "L\(rawValue)" }

    static func level(forElapsed elapsed: Double) -> GameLevel {
        switch elapsed {
        case ..<15: return .l1
        case ..<30: return .l2
        case ..<45: return .l3
        default: return .l4
        }
    }
}
