import SwiftUI

struct ScoreBadge: View {
    let icon: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.bold())
            Text(text)
                .font(.caption.bold())
        }
        .foregroundColor(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(tint.opacity(0.15)))
    }
}
