import SwiftUI

struct TrainingView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var logStore: LogStore
    @StateObject private var engine = BreathingEngine()

    var body: some View {
        NavigationStack {
            ZStack {
                ZenBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        heroCard
                        controlsCard
                        soundCard
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Breath Training")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Hero Card (Enso + Info + Button)

    private var heroCard: some View {
        VStack(spacing: 24) {
            EnsoBreathingView(
                phase: engine.phase,
                phaseRemaining: displayPhaseRemaining,
                phaseDuration: phaseDuration
            )

            // Session info row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session Remaining")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(ZenPalette.textSecondary)
                    Text(formatLong(seconds: displaySessionRemaining))
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(ZenPalette.textPrimary)
                }
                Spacer()
                Rectangle()
                    .fill(ZenPalette.divider)
                    .frame(width: 1, height: 40)
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Group")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(ZenPalette.textSecondary)
                    Text("\(displayGroupIndex)/\(max(1, settingsStore.settings.groupCount))")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(ZenPalette.textPrimary)
                }
            }

            // Start / Stop button
            Button(action: toggleSession) {
                Text(engine.isRunning ? "Stop" : "Begin")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(engine.isRunning ? Color.clear : ZenPalette.gold)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(engine.isRunning ? ZenPalette.danger : Color.clear, lineWidth: 2)
                    )
                    .foregroundColor(engine.isRunning ? ZenPalette.danger : ZenPalette.backgroundDeep)
            }
        }
        .zenCard()
    }

    // MARK: - Session Settings

    private var controlsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SESSION SETTINGS")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(ZenPalette.textMuted)
                .tracking(1)

            Stepper(value: bindingInt(keyPath: \.inhaleSeconds, range: 1...20), in: 1...20) {
                HStack {
                    Text("Inhale")
                        .foregroundColor(engine.isRunning ? ZenPalette.textMuted : ZenPalette.textPrimary)
                    Spacer()
                    Text("\(settingsStore.settings.inhaleSeconds)s")
                        .foregroundColor(engine.isRunning ? ZenPalette.textMuted : ZenPalette.gold)
                }
            }
            .disabled(engine.isRunning)
            .opacity(engine.isRunning ? 0.4 : 1.0)

            Stepper(value: bindingInt(keyPath: \.exhaleSeconds, range: 1...20), in: 1...20) {
                HStack {
                    Text("Exhale")
                        .foregroundColor(engine.isRunning ? ZenPalette.textMuted : ZenPalette.textPrimary)
                    Spacer()
                    Text("\(settingsStore.settings.exhaleSeconds)s")
                        .foregroundColor(engine.isRunning ? ZenPalette.textMuted : ZenPalette.gold)
                }
            }
            .disabled(engine.isRunning)
            .opacity(engine.isRunning ? 0.4 : 1.0)

            Stepper(value: bindingInt(keyPath: \.groupDurationMinutes, range: 1...10), in: 1...10) {
                HStack {
                    Text("Minutes")
                        .foregroundColor(engine.isRunning ? ZenPalette.textMuted : ZenPalette.textPrimary)
                    Spacer()
                    Text("\(settingsStore.settings.groupDurationMinutes)m")
                        .foregroundColor(engine.isRunning ? ZenPalette.textMuted : ZenPalette.gold)
                }
            }
            .disabled(engine.isRunning)
            .opacity(engine.isRunning ? 0.4 : 1.0)

            Stepper(value: bindingInt(keyPath: \.groupCount, range: 1...10), in: 1...10) {
                HStack {
                    Text("Groups")
                        .foregroundColor(engine.isRunning ? ZenPalette.textMuted : ZenPalette.textPrimary)
                    Spacer()
                    Text("\(settingsStore.settings.groupCount)")
                        .foregroundColor(engine.isRunning ? ZenPalette.textMuted : ZenPalette.gold)
                }
            }
            .disabled(engine.isRunning)
            .opacity(engine.isRunning ? 0.4 : 1.0)
        }
        .zenCard()
    }

    // MARK: - Sound & Reminders

    private var soundCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REMINDERS")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(ZenPalette.textMuted)
                .tracking(1)

            HStack {
                Text("Sound Profile")
                    .foregroundColor(ZenPalette.textPrimary)
                Spacer()
                Text(settingsStore.settings.soundProfile.displayName)
                    .foregroundColor(ZenPalette.textSecondary)
            }

            Toggle("Haptics", isOn: bindingBool(keyPath: \.hapticsEnabled))
                .tint(ZenPalette.gold)
                .disabled(engine.isRunning)
        }
        .zenCard()
    }

    // MARK: - Actions

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

    // MARK: - Formatting

    private func formatLong(seconds: Int) -> String {
        let minutes = seconds / 60
        let rem = seconds % 60
        if minutes > 0 {
            return "\(minutes)m \(rem)s"
        }
        return "\(rem)s"
    }

    // MARK: - Display State

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

    // MARK: - Bindings

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
