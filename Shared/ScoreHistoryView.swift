import SwiftUI

struct ScoreHistoryView: View {
    let scores: [PlayerScore]
    let highlightedID: UUID?
    let accentColor: Color

    var body: some View {
        VStack(spacing: 8) {
            if scores.isEmpty {
                Text("No scores yet — be the first!")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(scores.enumerated()), id: \.element.id) { index, entry in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.subheadline.bold())
                            .foregroundColor(rankColor(index))
                            .frame(width: 18)

                        Text(entry.playerName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()

                        Text("\(entry.score)")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(entry.id == highlightedID ? accentColor.opacity(0.22) : Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(entry.id == highlightedID ? accentColor : Color.clear, lineWidth: 1.5)
                            )
                    )
                }
            }
        }
    }

     private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .white.opacity(0.4)
        }
    }
}