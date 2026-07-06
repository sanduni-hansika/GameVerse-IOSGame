import SwiftUI

struct QuizRushView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = QuizRushViewModel()

    private static let historyKey = "QuizRushHistory"
    private let accentColors: [Color] = [.orange, .red]

    @State private var gameState: GameRoundState = .nameEntry
    @State private var playerName: String = ""

    @State private var scoreHistory: [PlayerScore] = ScoreHistoryStore.load(for: QuizRushView.historyKey)
    @State private var lastEntryID: UUID? = nil

    @State private var popupVisible = false
    @State private var popupOffset: CGFloat = 0
    @State private var popupOpacity: Double = 0

    private var trimmedName: String {
        playerName.trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        ZStack {
            backgroundGradient

            switch gameState {
            case .nameEntry:
                nameEntryView
            case .ready:
                readyView
            case .playing:
                playingShell
            case .gameOver:
                gameOverView
            }

            backButton
        }
        .navigationBarHidden(true)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.04, blue: 0.1),
                     Color(red: 0.22, green: 0.07, blue: 0.05)],
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

    private var nameEntryView: some View {
        VStack(spacing: 26) {
            GameTitleBadge(systemImage: "questionmark.circle.fill", title: "Quiz Rush", colors: accentColors)

            Text("Enter your name to start the quiz.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))

            PlayerNameField(name: $playerName, accentColors: accentColors)
                .padding(.horizontal, 36)

            Button(action: { gameState = .ready }) {
                Text("Continue")
                    .font(.headline.bold())
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(
                        Capsule().fill(
                            trimmedName.isEmpty
                                ? AnyShapeStyle(Color.white.opacity(0.15))
                                : AnyShapeStyle(LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing))
                        )
                    )
                    .foregroundColor(trimmedName.isEmpty ? .white.opacity(0.4) : .black)
            }
            .disabled(trimmedName.isEmpty)
        }
        .padding()
    }


    private var readyView: some View {
        ScrollView {
            VStack(spacing: 22) {
                GameTitleBadge(systemImage: "questionmark.circle.fill", title: "Quiz Rush", colors: accentColors)

                Text("10 live trivia questions. Answer fast, build a streak for bonus points.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Correct answer scores and builds your streak", systemImage: "checkmark.circle.fill")
                    Label("Wrong answer costs a small penalty", systemImage: "xmark.circle.fill")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.65))

                playerBadge

                Button(action: startGame) {
                    Text("Start Quiz")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 16)
                        .background(
                            Capsule().fill(LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: accentColors[0].opacity(0.5), radius: 14, y: 6)
                }

                ScoreHistoryView(
                    title: "TOP SCORES",
                    scores: scoreHistory,
                    accentColor: accentColors[0]
                )
                .padding(.horizontal, 28)
                .padding(.top, 6)
            }
            .padding(.vertical, 24)
        }
    }

    private var playerBadge: some View {
        HStack(spacing: 6) {
            Text("Playing as")
                .foregroundColor(.white.opacity(0.5))
            Text(trimmedName)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            Button("Change") { gameState = .nameEntry }
                .font(.caption.bold())
                .foregroundColor(.orange)
        }
        .font(.footnote)
    }

     private var playingShell: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingView
            case .failed:
                errorView
            case .loaded:
                quizContentView
            }
        }
        .task { await viewModel.load() }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
            Text("Loading questions…")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
            Text("Couldn't load questions")
                .font(.headline)
                .foregroundColor(.white)
            Text("Check your connection and try again.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.5))

            Button(action: { Task { await viewModel.load() } }) {
                Text("Retry")
                    .font(.headline.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(
                        Capsule().fill(LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing))
                    )
            }
            .padding(.top, 6)
        }
        .padding()
    }

    private var quizContentView: some View {
        VStack(spacing: 24) {
            hud

            if let question = viewModel.currentQuestion {
                VStack(spacing: 22) {
                    Text(question.question.htmlDecoded)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 26)
                        .frame(minHeight: 90)

                    VStack(spacing: 12) {
                        ForEach(viewModel.answerOptions, id: \.self) { option in
                            AnswerOptionButton(
                                text: option,
                                style: style(for: option),
                                isDisabled: viewModel.isAnswerLocked
                            ) {
                                handleSelect(option)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }

            Spacer()
        }
        .overlay(pointsPopup)
        .padding(.top, 4)
    }

    private var hud: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(viewModel.score)")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("QUESTION")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(viewModel.currentIndex + 1) of \(viewModel.totalQuestions)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("STREAK")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(viewModel.streak)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }

            LevelProgressBar(
                total: viewModel.totalQuestions,
                currentIndex: viewModel.currentIndex,
                colors: accentColors
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }

    private var pointsPopup: some View {
        Group {
            if popupVisible {
                Text(viewModel.lastPointsEarned >= 0 ? "+\(viewModel.lastPointsEarned)" : "\(viewModel.lastPointsEarned)")
                    .font(.title.bold())
                    .foregroundColor(viewModel.lastPointsEarned >= 0 ? .green : .red)
                    .offset(y: popupOffset)
                    .opacity(popupOpacity)
            }
        }
    }

    private var gameOverView: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.white.opacity(0.6))
                    Text("Quiz Complete")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)

                Text("\(viewModel.score)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(.orange)

                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))

                leaderboardBadge

                HStack(spacing: 14) {
                    Button(action: { dismiss() }) {
                        Text("Home")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1.5))
                    }

                    Button(action: startGame) {
                        Text("Play Again")
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(LinearGradient(colors: accentColors, startPoint: .leading, endPoint: .trailing))
                            )
                            .shadow(color: accentColors[0].opacity(0.5), radius: 14, y: 6)
                    }
                }
                .padding(.top, 4)

                ScoreHistoryView(
                    title: "TOP SCORES",
                    scores: scoreHistory,
                    highlightID: lastEntryID,
                    accentColor: accentColors[0]
                )
                .padding(.horizontal, 28)
                .padding(.top, 10)
            }
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private var leaderboardBadge: some View {
        if lastEntryID != nil {
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill").foregroundColor(.yellow)
                Text(scoreHistory.first?.id == lastEntryID ? "New personal best" : "Made the top 5")
                    .foregroundColor(.yellow)
            }
            .font(.subheadline.bold())
        }
    }