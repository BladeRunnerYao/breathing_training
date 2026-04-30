import SwiftUI

struct TrainingView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var logStore: LogStore
    @StateObject private var engine = BreathingEngine()

    var body: some View {
        NavigationStack {
            ZStack {
                CalmBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        heroCard
                        statusCard
                        controlsCard
                        soundCard
                        actionCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Breath Training")
        }
    }

    private var heroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill((engine.phase == .inhale ? CalmPalette.inhale : CalmPalette.exhale).opacity(0.18))
                    .frame(width: 220, height: 220)
                    .overlay(
                        Circle()
                            .stroke((engine.phase == .inhale ? CalmPalette.inhale : CalmPalette.exhale).opacity(0.35), lineWidth: 2)
                    )
                    .scaleEffect(engine.phase == .inhale ? 1.03 : 0.90)
                    .animation(.easeInOut(duration: Double(phaseDuration)), value: engine.phase)

                VStack(spacing: 6) {
                    Text(engine.phase == .inhale ? "Inhale" : "Exhale")
                        .font(.custom("Avenir Next", size: 28))
                        .foregroundColor(CalmPalette.accent)
                    Text(format(seconds: displayPhaseRemaining))
                        .font(.custom("Avenir Next", size: 44))
                        .foregroundColor(.primary)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatLong(seconds: displaySessionRemaining))
                        .font(.custom("Avenir Next", size: 20))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Group")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(displayGroupIndex)/\(max(1, settingsStore.settings.groupCount))")
                        .font(.custom("Avenir Next", size: 20))
                }
            }

            Button(action: toggleSession) {
                Text(engine.isRunning ? "Stop" : "Start Training")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(engine.isRunning ? Color.red : CalmPalette.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .softCard()
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(engine.isRunning ? "Running" : "Ready")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Phase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(engine.phase == .inhale ? "Inhale" : "Exhale")
                        .font(.title2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(format(seconds: engine.phaseRemaining))
                        .font(.title2)
                }
            }

            ProgressView(value: progressValue)
        }
        .softCard()
    }

    private var controlsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Settings")
                .font(.headline)

            Stepper(value: bindingInt(keyPath: \.inhaleSeconds, range: 1...20), in: 1...20) {
                HStack {
                    Text("Inhale")
                    Spacer()
                    Text("\(settingsStore.settings.inhaleSeconds)s")
                        .foregroundColor(.secondary)
                }
            }
            .disabled(engine.isRunning)

            Stepper(value: bindingInt(keyPath: \.exhaleSeconds, range: 1...20), in: 1...20) {
                HStack {
                    Text("Exhale")
                    Spacer()
                    Text("\(settingsStore.settings.exhaleSeconds)s")
                        .foregroundColor(.secondary)
                }
            }
            .disabled(engine.isRunning)

            Stepper(value: bindingInt(keyPath: \.groupDurationMinutes, range: 1...10), in: 1...10) {
                HStack {
                    Text("Minutes per Group")
                    Spacer()
                    Text("\(settingsStore.settings.groupDurationMinutes)m")
                        .foregroundColor(.secondary)
                }
            }
            .disabled(engine.isRunning)

            Stepper(value: bindingInt(keyPath: \.groupCount, range: 1...10), in: 1...10) {
                HStack {
                    Text("Group Count")
                    Spacer()
                    Text("\(settingsStore.settings.groupCount)")
                        .foregroundColor(.secondary)
                }
            }
            .disabled(engine.isRunning)
        }
        .softCard()
    }

    private var soundCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminders")
                .font(.headline)

            HStack {
                Text("Sound Profile")
                Spacer()
                Text(settingsStore.settings.soundProfile.displayName)
                    .foregroundColor(.secondary)
            }

            Toggle("Haptics", isOn: bindingBool(keyPath: \.hapticsEnabled))
                .disabled(engine.isRunning)
        }
        .softCard()
    }

    private var actionCard: some View {
        VStack(spacing: 12) {
            if engine.isRunning {
                Text("Group \(engine.currentGroupIndex) / \(settingsStore.settings.groupCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("Use the Start button above to begin training.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var progressValue: Double {
        guard engine.isRunning else { return 0.0 }
        let total = max(1, settingsStore.settings.groupDurationMinutes) * 60
        let remaining = max(0, engine.groupRemaining)
        return 1.0 - (Double(remaining) / Double(total))
    }

    private func toggleSession() {
        if engine.isRunning {
            engine.stop(completed: false)
        } else {
            let settings = settingsStore.settings
            engine.start(settings: settings) { log in
                logStore.add(log)
            }
        }
    }

    private func format(seconds: Int) -> String {
        return "\(seconds)s"
    }

    private func formatLong(seconds: Int) -> String {
        let minutes = seconds / 60
        let rem = seconds % 60
        if minutes > 0 {
            return "\(minutes)m \(rem)s"
        }
        return "\(rem)s"
    }

    private var displayPhaseRemaining: Int {
        if engine.isRunning {
            return engine.phaseRemaining
        }
        return engine.phase == .inhale ? settingsStore.settings.inhaleSeconds : settingsStore.settings.exhaleSeconds
    }

    private var displaySessionRemaining: Int {
        if engine.isRunning {
            return engine.sessionRemaining
        }
        return max(1, settingsStore.settings.groupDurationMinutes) * 60 * max(1, settingsStore.settings.groupCount)
    }

    private var displayGroupIndex: Int {
        if engine.isRunning {
            return engine.currentGroupIndex
        }
        return 1
    }

    private var phaseDuration: Int {
        switch engine.phase {
        case .inhale:
            return max(1, settingsStore.settings.inhaleSeconds)
        case .exhale:
            return max(1, settingsStore.settings.exhaleSeconds)
        }
    }

    private func bindingInt(keyPath: WritableKeyPath<BreathSettings, Int>, range: ClosedRange<Int>) -> Binding<Int> {
        Binding<Int>(
            get: { settingsStore.settings[keyPath: keyPath] },
            set: { newValue in
                settingsStore.settings[keyPath: keyPath] = min(max(newValue, range.lowerBound), range.upperBound)
            }
        )
    }

    private func bindingBool(keyPath: WritableKeyPath<BreathSettings, Bool>) -> Binding<Bool> {
        Binding<Bool>(
            get: { settingsStore.settings[keyPath: keyPath] },
            set: { newValue in settingsStore.settings[keyPath: keyPath] = newValue }
        )
    }
}
