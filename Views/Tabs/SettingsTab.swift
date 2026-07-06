import SwiftUI

struct SettingsTab: View {
    @AppStorage("dailyChallengeEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("dailyChallengeHour") private var challengeHour: Int = 18
    @AppStorage("dailyChallengeMinute") private var challengeMinute: Int = 0

    @State private var showResetConfirmation = false
    @State private var showPermissionDeniedAlert = false
    @State private var resetDone = false

    private var challengeTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = challengeHour
                components.minute = challengeMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                challengeHour = comps.hour ?? 18
                challengeMinute = comps.minute ?? 0
                if notificationsEnabled {
                    NotificationService.shared.scheduleDailyChallenge(hour: challengeHour, minute: challengeMinute)
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        dailyChallengeCard
                        dataCard
                        aboutFooter
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
        .confirmationDialog(
            "Reset all stats?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) { resetAllStats() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears every recorded game session and every leaderboard entry, for all three modes. This can't be undone.")
        }
        .alert("Notifications Disabled", isPresented: $showPermissionDeniedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable notifications for GameVerse in Settings to receive your daily challenge reminder.")
        }
        .alert("Stats Reset", isPresented: $resetDone) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All game sessions and leaderboards have been cleared.")
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.04, green: 0.04, blue: 0.13), Color(red: 0.1, green: 0.05, blue: 0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        Text("Settings")
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
    }

    private var dailyChallengeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Daily Challenge", systemImage: "bell.fill")
                .font(.headline)
                .foregroundColor(.white)

            Toggle(isOn: Binding(
                get: { notificationsEnabled },
                set: { newValue in handleToggle(newValue) }
            )) {
                Text("Remind me to play every day")
                    .foregroundColor(.white.opacity(0.85))
            }
            .tint(.green)

            if notificationsEnabled {
                DatePicker("Reminder time", selection: challengeTime, displayedComponents: .hourAndMinute)
                    .foregroundColor(.white.opacity(0.85))
                    .colorScheme(.dark)
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.06)))
    }

    private var dataCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Data", systemImage: "externaldrive.fill")
                .font(.headline)
                .foregroundColor(.white)

            Text("Clears every game session and every mode's leaderboard. Your name and notification settings are kept.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.55))

            Button(role: .destructive, action: { showResetConfirmation = true }) {
                Text("Reset All Stats")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.red.opacity(0.8)))
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.06)))
    }

    private var aboutFooter: some View {
        VStack(spacing: 4) {
            Text("GameVerse")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.4))
            Text("Let's Play")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.top, 8)
    }

    private func handleToggle(_ enabled: Bool) {
        if enabled {
            NotificationService.shared.requestPermission { granted in
                if granted {
                    notificationsEnabled = true
                    NotificationService.shared.scheduleDailyChallenge(hour: challengeHour, minute: challengeMinute)
                } else {
                    notificationsEnabled = false
                    showPermissionDeniedAlert = true
                }
            }
        } else {
            notificationsEnabled = false
            NotificationService.shared.cancelDailyChallenge()
        }
    }

    private func resetAllStats() {
        SessionStore.reset()
        ScoreHistoryStore.resetAll()
        resetDone = true
    }
}

#Preview {
    SettingsTab()
}
