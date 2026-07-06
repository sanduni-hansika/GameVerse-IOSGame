import Foundation

struct PlayerScore: Identifiable, Codable, Equatable {
    let id: UUID
    let playerName: String
    let score: Int
    let date: Date
}