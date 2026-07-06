import SwiftUI

struct PlayerNameField: View {
    @Binding var name: String
    var accentColors: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR NAME")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.5))
                .tracking(1.2)

            TextField("Enter your name", text: $name)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(borderStyle, lineWidth: 1.5)
                        )
                )
        }
    }

    private var borderStyle: AnyShapeStyle {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return AnyShapeStyle(Color.white.opacity(0.12))
        }
        return AnyShapeStyle(
            LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing)
        )
    }
}
