import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var vm = StatsVM()
    @State private var selectedMode: GameMode = .tapFrenzy

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        totalsRow
                        bestsRow
                        modePicker
                        chartCard
                        recentGamesSection
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear { vm.refresh() }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.04, green: 0.04, blue: 0.13),
                     Color(red: 0.1, green: 0.05, blue: 0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("Stats")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text("Every game you've played, across every mode")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 40)
    }

    private var totalsRow: some View {
        HStack(spacing: 12) {
            statCard(title: "Games Played", value: "\(vm.totalGamesPlayed)", icon: "gamecontroller.fill", tint: .blue)
            statCard(title: "Total Score", value: "\(vm.totalScore)", icon: "sum", tint: .green)
        }
    }

    private func statCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(tint)
            Text(value)
                .font(.title.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06)))
    }

    private var bestsRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PERSONAL BESTS")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.4))

            HStack(spacing: 10) {
                ForEach(GameMode.allCases) { mode in
                    VStack(spacing: 6) {
                        Image(systemName: mode.systemImage)
                            .foregroundColor(mode.colors.first)
                        Text("\(vm.personalBest(for: mode))")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Text(mode.displayName)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.06)))
                }
            }
        }
    }

    private var modePicker: some View {
        Picker("Mode", selection: $selectedMode) {
            ForEach(GameMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score progression · \(selectedMode.displayName)")
                .font(.subheadline.bold())
                .foregroundColor(.white)

            let sessions = vm.chartSessions(for: selectedMode)

            if sessions.isEmpty {
                Text("Play \(selectedMode.displayName) to see your progress here.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, minHeight: 140)
            } else {
                Chart(Array(sessions.enumerated()), id: \.element.id) { index, session in
                    BarMark(
                        x: .value("Game", "#\(index + 1)"),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(selectedMode.colors.first ?? .blue)
                    .cornerRadius(4)
                }
                .frame(height: 160)
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel().foregroundStyle(Color.white.opacity(0.5))
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel().foregroundStyle(Color.white.opacity(0.4))
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06)))
    }

    private var recentGamesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RECENT GAMES")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.4))

            if vm.recentSessions.isEmpty {
                Text("No games recorded yet — go play something!")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(vm.recentSessions) { session in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: session.mode.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 36, height: 36)
                                Image(systemName: session.mode.systemImage)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.mode.displayName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white)
                                Text(session.timestamp, style: .relative)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.45))
                            }
                            Spacer()
                            Text("\(session.score)")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.05)))
                    }
                }
            }
        }
    }
}

#Preview {
    StatsTab()
}