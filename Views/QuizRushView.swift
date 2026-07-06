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

    // MARK: - Chrome

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

    // MARK: - Name Entry Screen

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

    // MARK: - Ready Screen

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