import SwiftUI

struct ScoreHistoryView: View {
    let title: String
    let scores: [PlayerScore]
    var highlightID: UUID? = nil
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.5))
                .tracking(1.2)

            if scores.isEmpty {
                Text("No scores yet — be the first")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(scores.enumerated()), id: \.element.id) { index, entry in
                        row(rank: index + 1, entry: entry)
                    }
                }
            }
        }
    }

    private func row(rank: Int, entry: PlayerScore) -> some View {
        let isHighlighted = entry.id == highlightID
        return HStack(spacing: 12) {
            Text("\(rank)")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 16)

            Text(entry.playerName)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            Text("\(entry.score)")
                .font(.subheadline.bold())
                .foregroundColor(isHighlighted ? accentColor : .white.opacity(0.75))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHighlighted ? accentColor.opacity(0.15) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHighlighted ? accentColor.opacity(0.6) : Color.clear, lineWidth: 1.2)
                )
        )
    }
}
