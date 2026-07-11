import SwiftUI

struct PlayerNameField: View {
    let gameTitle: String
    let subtitle: String
    let accentColors: [Color]
    let systemImage: String
    let onContinue: (String) -> Void

    @State private var name: String = ""
    @FocusState private var isFocused: Bool

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(spacing: 26) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 84, height: 84)
                    .shadow(color: accentColors.first?.opacity(0.5) ?? .clear, radius: 16, y: 6)
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 6) {
                Text(gameTitle)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR NAME")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.4))

                TextField("Enter your name", text: $name)
                    .focused($isFocused)
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isFocused ? (accentColors.first ?? .white) : Color.white.opacity(0.15), lineWidth: 1.5)
                            )
                    )
                    .submitLabel(.done)
                    .onSubmit { attemptContinue() }
            }
            .padding(.horizontal, 32)

            Button(action: attemptContinue) {
                Text("Continue")
                    .font(.title3.bold())
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing)
                        )
                    )
                    .opacity(trimmedName.isEmpty ? 0.4 : 1.0)
            }
            .disabled(trimmedName.isEmpty)
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .onAppear { isFocused = true }
    }

    private func attemptContinue() {
       print("BUTTON CLICKED")
    print("NAME:", trimmedName)

    guard !trimmedName.isEmpty else {
        print("EMPTY NAME")
        return
    }

    onContinue(trimmedName)

    }
}
