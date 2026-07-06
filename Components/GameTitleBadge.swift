import SwiftUI

struct GameTitleBadge: View {
    let playerName: String
    let accentColor: Color
    let onChangeName: () -> Void

      var body: some View {
        HStack(spacing: 4) {
            Text("Playing as")
                .foregroundColor(.white.opacity(0.5))
            Text(playerName)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            Text("·")
                .foregroundColor(.white.opacity(0.3))
            Button(action: onChangeName) {
                Text("Change")
                    .foregroundColor(accentColor)
                    .fontWeight(.semibold)
            }
        }
        .font(.footnote)
    }
}
