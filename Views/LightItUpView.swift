import SwiftUI

struct LightItUpView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = LightItUpVM()

    var body: some View {
        ZStack {
            backgroundGradient

            switch vm.roundState {
            case .nameEntry:
                PlayerNameField(
                    gameTitle: "💡 Light It Up",
                    subtitle: "Enter your name before the grid lights up.",
                    accentColors: [.blue, .purple],
                    systemImage: "square.grid.3x3.fill"
                ) { name in vm.confirmName(name) }

            case .ready:
                readyView

            case .playing:
                playingView

            case .gameOver:
                ResultView(
                    mode: .lightItUp,
                    headline: "⏱ Round Over!",
                    score: vm.score,
                    subtitle: "Final Score",
                    extraInfo: "Reached \(vm.level.label)",
                    statusMessage: vm.statusMessage,
                    scores: vm.scores,
                    highlightedID: vm.lastEntryID,
                    onHome: { dismiss() },
                    onPlayAgain: { vm.startGame() }
                )
            }

            if vm.showLevelUpFlash {
                levelUpFlash
            }

            backButton
        }
        .navigationBarHidden(true)
        .onAppear { vm.loadLeaderboard() }
        .onDisappear { vm.stopTimers() }
    }


    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.04, green: 0.05, blue: 0.14),
                     Color(red: 0.08, green: 0.05, blue: 0.24)],
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

    private var levelUpFlash: some View {
        ZStack {
            vm.level.glowColor.opacity(0.22).ignoresSafeArea()
            Text("LEVEL \(vm.level.rawValue)")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: vm.level.glowColor, radius: 20)
        }
        .transition(.opacity)
        .allowsHitTesting(false)
    }


    private var readyView: some View {
        VStack(spacing: 18) {
            Text("💡 Light It Up")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("A card lights up — tap it before it goes dark.\nThe grid grows and the window shrinks as you go.")
                .font(.headline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            HStack(spacing: 10) {
                ForEach(GameLevel.allCases, id: \.self) { lvl in
                    VStack(spacing: 4) {
                        Circle().fill(lvl.glowColor).frame(width: 12, height: 12)
                        Text(lvl.label)
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }

            GameTitleBadge(playerName: vm.playerName, accentColor: .blue) {
                vm.roundState = .nameEntry
            }

            if let best = vm.scores.first?.score {
                ScoreBadge(icon: "trophy.fill", text: "High Score: \(best)", tint: .yellow)
            }

            Button(action: vm.startGame) {
                Text("Start Game")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 14, y: 6)
            }
            .padding(.top, 6)
        }
        .padding()
    }


    private var playingView: some View {
        VStack(spacing: 0) {
            hud
            Spacer()

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: vm.level.columns),
                spacing: 14
            ) {
                ForEach(vm.cards) { card in
                    LightCardView(isLit: card.isLit, glowColor: vm.level.glowColor) {
                        vm.handleTap(card)
                    }
                }
            }
            .padding(.horizontal, 28)
            .animation(.easeInOut(duration: 0.25), value: vm.level)

            Spacer()
            Spacer()
        }
        .onAppear { vm.setupRound() }
    }

    private var hud: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text("\(vm.score)")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("LEVEL")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text(vm.level.label)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(vm.level.glowColor)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("TIME")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                Text(String(format: "%.0f", max(vm.timeRemaining, 0)))
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(vm.timeRemaining <= 8 ? .red : .white)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 24)
    }
}

#Preview {
    NavigationStack { LightItUpView() }
}
