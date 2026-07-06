import SwiftUI

struct LevelProgressBar: View {
    let total: Int
    let completed: Int
    let colors: [Color]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(
                         index < completed
                            ? AnyShapeStyle(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color.white.opacity(0.12))
                    )
                    .frame(height: 5)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: completed)
    }
}