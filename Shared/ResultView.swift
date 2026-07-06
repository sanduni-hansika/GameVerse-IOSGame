import SwiftUI

struct ResultView: View {
    let mode: GameMode
    let headline: String
    let score: Int
    let subtitle: String
    let extraInfo: String?
    let statusMessage: String?
    let scores: [PlayerScore]
    let highlightedID: UUID?
    let onHome: () -> Void
    let onPlayAgain: () -> Void

    private var shareText: String {
        "I just scored \(score) on \(mode.displayName) in GameVerse — beat that!"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(headline)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 24)

                Text("\(score)")
                    .font(.system(size: 62, weight: .black, design: .rounded))
                    .foregroundColor(mode.colors.first ?? .white)

                Text(subtitle)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))

                if let extraInfo {
                    Text(extraInfo)
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.7))
                }

                if let statusMessage {
                    Text(statusMessage)
                        .font(.title3.bold())
                        .foregroundColor(.yellow)
                        .padding(.top, 2)
                }

                HStack(spacing: 14) {
                    Button(action: onHome) {
                        Text("Home")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 14)
                            .background(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1.5))
                    }

                    Button(action: onPlayAgain) {
                        Text("Play Again")
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(
                                    LinearGradient(colors: mode.colors, startPoint: .leading, endPoint: .trailing)
                                )
                            )
                            .shadow(color: mode.colors.first?.opacity(0.5) ?? .clear, radius: 12, y: 6)
                    }
                }
                .padding(.top, 8)

                ShareLink(item: shareText) {
                    Label("Share Score", systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                .padding(.top, 4)

                VStack(alignment: .leading, spacing: 10) {
                    Text("TOP SCORES")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.leading, 4)

                    ScoreHistoryView(scores: scores, highlightedID: highlightedID, accentColor: mode.colors.first ?? .white)
                }
                .padding(.top, 20)
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
