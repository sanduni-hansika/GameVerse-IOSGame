import SwiftUI

struct FloatingScoreView: View {

    let text: String

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {

        Text(text)
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: .yellow.opacity(0.8), radius: 8)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {

                withAnimation(.easeOut(duration: 0.55)) {

                    offsetY = -40
                    opacity = 0
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FloatingScoreView(text: "+10")
    }
}
