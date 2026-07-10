import SwiftUI

struct TapFrenzyView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = TapFrenzyVM()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient

                switch vm.roundState {
                case .nameEntry:
                    PlayerNameField(
                        gameTitle: "⚡️ Tap Frenzy",
                        subtitle: "Enter your name to start the clock.",
                        accentColors: [.orange, .pink],
                        systemImage: "bolt.fill"
                    ) { name in vm.confirmName(name) }

                case .ready:
                    readyView

                case .playing:
                    playingView(in: geo)

                case .gameOver:
                    ResultView(
                        mode: .tapFrenzy,
                        headline: "⏱ Time's Up!",
                        score: vm.score,
                        subtitle: "Final Score",
                        extraInfo: nil,
                        statusMessage: vm.statusMessage,
                        scores: vm.scores,
                        highlightedID: vm.lastEntryID,
                        onHome: { dismiss() },
                        onPlayAgain: { vm.startGame() }
                    )
                }

                backButton
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .navigationBarHidden(true)
        .onAppear { vm.loadLeaderboard() }
        .onDisappear { vm.stopTimers() }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.05, blue: 0.15),
                     Color(red: 0.14, green: 0.05, blue: 0.26)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var backButton: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                }
                .padding(.leading, 16)
                .padding(.top, 12)
                Spacer()
            }
            Spacer()
        }
    }


    private var readyView: some View {
        VStack(spacing: 20) {
            Text("⚡️ Tap Frenzy")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Tap as many times as you can in \(Int(vm.gameDuration)) seconds!")
                .font(.headline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(alignment: .leading, spacing: 10) {
                Label("Button shrinks as time runs out", systemImage: "arrow.down.right.and.arrow.up.left.circle.fill")
                Label("Button jumps to a new spot every 2s", systemImage: "arrow.left.arrow.right.circle.fill")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white.opacity(0.65))

            GameTitleBadge(playerName: vm.playerName, accentColor: .orange) {
                vm.roundState = .nameEntry
            }
            .padding(.top, 4)

            if let best = vm.scores.first?.score {
                ScoreBadge(icon: "trophy.fill", text: "High Score: \(best)", tint: .yellow)
                    .padding(.top, 4)
            }

            Button(action: vm.startGame) {
                Text("Start Game")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                    )
                    .shadow(color: .pink.opacity(0.5), radius: 14, y: 6)
            }
            .padding(.top, 10)
        }
        .padding()
    }


    private func playingView(in geo: GeometryProxy) -> some View {
        ZStack {
            VStack {
                hud
                Spacer()
            }

            tapButton
                .offset(vm.buttonOffset)
                .animation(.spring(response: 0.45, dampingFraction: 0.65), value: vm.buttonOffset)
                .animation(.easeInOut(duration: 0.25), value: vm.buttonSize)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)

            ForEach(vm.popups) { popup in
                Text("+1")
                    .font(.title.bold())
                    .foregroundColor(.green)
                    .shadow(color: .black.opacity(0.4), radius: 3)
                    .position(x: popup.position.x, y: popup.position.y + popup.offsetY)
                    .opacity(popup.opacity)
            }
        }
        .onAppear { vm.setupRound(in: geo) }
    }

    private var hud: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text("\(vm.score)")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("TIME")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text(String(format: "%.1f", max(vm.timeRemaining, 0)))
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(vm.timeRemaining <= 3 ? .red : .white)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }

    private var tapButton: some View {
        Button(action: vm.handleTap) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange, Color.pink],
                            center: .center, startRadius: 5, endRadius: vm.buttonSize
                        )
                    )
                    .frame(width: vm.buttonSize, height: vm.buttonSize)
                    .shadow(color: .pink.opacity(0.6), radius: 16, y: 8)

                Text("TAP")
                    .font(.system(size: max(14, vm.buttonSize * 0.18), weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .scaleEffect(vm.isPressed ? 0.88 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { TapFrenzyView() }
}