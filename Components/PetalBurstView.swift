import SwiftUI

struct PetalBurstView: View {

    @State private var animate = false

    var body: some View {

        ZStack {

            ForEach(0..<8, id: \.self) { index in

                Text("🌸")
                    .font(.system(size: 16))
                    .offset(
                        x: animate ? cos(Double(index) * .pi / 4) * 40 : 0,
                        y: animate ? sin(Double(index) * .pi / 4) * 40 : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.4 : 1.0)
            }
        }
        .onAppear {

            withAnimation(.easeOut(duration: 0.45)) {

                animate = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PetalBurstView()
    }
}
