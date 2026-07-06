import SwiftUI

struct GameTitleBadge: View {
    let systemImage: String
    let title: String
    let colors: [Color]

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 62, height: 62)
                    .shadow(color: colors.first?.opacity(0.5) ?? .clear, radius: 12, y: 4)

                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
    }
}
