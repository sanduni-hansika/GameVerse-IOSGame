import SwiftUI

struct LightCardView: View {
    let isLit: Bool
    let glowColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 18)
                .fill(isLit ? glowColor : Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isLit ? glowColor : Color.white.opacity(0.15),
                                lineWidth: isLit ? 3 : 1)
                )
                .shadow(color: isLit ? glowColor.opacity(0.7) : .clear, radius: 14)
                .scaleEffect(isLit ? 1.05 : 1.0)
                .frame(height: 92)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLit)
    }
}
