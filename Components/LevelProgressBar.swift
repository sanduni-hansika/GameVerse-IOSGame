import SwiftUI

struct LevelProgressBar: View {
    let total: Int
    let currentIndex: Int
    let colors: [Color]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<max(total, 1), id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        i <= currentIndex
                            ? AnyShapeStyle(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color.white.opacity(0.12))
                    )
                    .frame(height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
    }
}