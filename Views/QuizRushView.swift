import SwiftUI

struct QuizRushView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = QuizRushVM()

    @State private var popupAmount: Int = 0
    @State private var popupOpacity: Double = 0
    @State private var popupOffsetY: CGFloat = 0

    var body: some View {
        ZStack {
            backgroundGradient

            switch vm.roundState {
            case .nameEntry:
                PlayerNameField(
                    gameTitle: "❓ Quiz Rush",
                    subtitle: "Enter your name before the questions start.",
                    accentColors: [.orange, .red],
                    systemImage: "questionmark.circle.fill"
                ) { name in vm.confirmName(name) }

            case .ready:
                readyView

            case .playing:
                playingShell

            case .gameOver:
                ResultView(
                    mode: .quizRush,
                    headline: "🏁 Quiz Complete",
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
        .navigationBarHidden(true)
        .onAppear { vm.loadLeaderboard() }
    }


    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.04, green: 0.05, blue: 0.14),
                     Color(red: 0.10, green: 0.03, blue: 0.06)],
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
        VStack(spacing: 18) {
            Text("❓ Quiz Rush")
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("10 live trivia questions. Answer fast, build a streak for bonus points.")
                .font(.headline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            VStack(alignment: .leading, spacing: 6) {
                Label("Correct answer scores and builds your streak", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Label("Wrong answer costs a small penalty", systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .font(.footnote.weight(.medium))

            GameTitleBadge(playerName: vm.playerName, accentColor: .orange) {
                vm.roundState = .nameEntry
            }

            if let best = vm.scores.first?.score {
                ScoreBadge(icon: "trophy.fill", text: "High Score: \(best)", tint: .yellow)
            }

            Button(action: vm.startGame) {
                Text("Start Quiz")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                        )
                    )
                    .shadow(color: .red.opacity(0.5), radius: 14, y: 6)
            }
            .padding(.top, 6)

            if !vm.scores.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("TOP SCORES")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.4))
                    ScoreHistoryView(scores: vm.scores, highlightedID: nil, accentColor: .orange)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
        }
        .padding()
    }


    private var playingShell: some View {
        Group {
            switch vm.viewState {
            case .loading:
                loadingView
            case .failed:
                errorView
            case .loaded:
                quizContentView
            }
        }
        .task { await vm.load() }
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.3)
            Text("Loading questions…")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            Text("Couldn't load questions")
                .font(.headline)
                .foregroundColor(.white)
            Text("Check your connection and try again.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { Task { await vm.load() } }) {
                Text("Retry")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)))
            }
            .padding(.top, 6)
        }
        .padding()
    }


    private var quizContentView: some View {
        VStack(spacing: 20) {
            hud

            LevelProgressBar(total: vm.questions.count, completed: vm.currentIndex, colors: [.orange, .red])
                .padding(.horizontal, 24)

            if let question = vm.currentQuestion {
                Text(question.question)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                    .padding(.top, 8)

                VStack(spacing: 10) {
                    ForEach(question.answers, id: \.self) { answer in
                        answerButton(answer, correctAnswer: question.correctAnswer)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding(.top, 60)
        .overlay(alignment: .top) { scorePopup }
    }

    private var hud: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.45))
                Text("\(vm.score)")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("QUESTION")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.45))
                Text("\(min(vm.currentIndex + 1, vm.questions.count)) of \(vm.questions.count)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("STREAK")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.45))
                Text("🔥 \(vm.streak)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 24)
    }

    private func answerButton(_ answer: String, correctAnswer: String) -> some View {
        Button(action: { handleAnswerTap(answer) }) {
            Text(answer)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(textColor(for: answer, correctAnswer: correctAnswer))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(backgroundColor(for: answer, correctAnswer: correctAnswer))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(borderColor(for: answer, correctAnswer: correctAnswer), lineWidth: 1.5)
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(vm.answerState != .none)
        .animation(.easeInOut(duration: 0.2), value: vm.answerState)
    }


    private func backgroundColor(for answer: String, correctAnswer: String) -> Color {
        guard vm.answerState != .none else { return Color.white.opacity(0.06) }
        if answer == correctAnswer { return .green.opacity(0.22) }
        if answer == vm.selectedAnswer && vm.answerState == .wrong { return .red.opacity(0.22) }
        return Color.white.opacity(0.03)
    }

    private func borderColor(for answer: String, correctAnswer: String) -> Color {
        guard vm.answerState != .none else { return Color.white.opacity(0.14) }
        if answer == correctAnswer { return .green }
        if answer == vm.selectedAnswer && vm.answerState == .wrong { return .red }
        return Color.white.opacity(0.06)
    }

    private func textColor(for answer: String, correctAnswer: String) -> Color {
        guard vm.answerState != .none else { return .white }
        if answer == correctAnswer { return .white }
        if answer == vm.selectedAnswer && vm.answerState == .wrong { return .white }
        return .white.opacity(0.35)
    }


    private func handleAnswerTap(_ answer: String) {
        guard vm.answerState == .none else { return }
        let delta = vm.submit(answer)
        triggerScorePopup(delta)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            vm.advance()
        }
    }

    private func triggerScorePopup(_ amount: Int) {
        popupAmount = amount
        popupOffsetY = 0
        popupOpacity = 1
        withAnimation(.easeOut(duration: 0.7)) {
            popupOffsetY = -30
            popupOpacity = 0
        }
    }

    private var scorePopup: some View {
        Group {
            if popupOpacity > 0 {
                Text(popupAmount >= 0 ? "+\(popupAmount)" : "\(popupAmount)")
                    .font(.title2.bold())
                    .foregroundColor(popupAmount >= 0 ? .green : .red)
                    .offset(y: popupOffsetY)
                    .opacity(popupOpacity)
                    .padding(.top, 62)
            }
        }
    }
}

#Preview {
    NavigationStack { QuizRushView() }
}
