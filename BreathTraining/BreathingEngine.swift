import Foundation

final class BreathingEngine: ObservableObject {
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var phase: BreathPhase = .inhale
    @Published private(set) var phaseRemaining: Int = 0
    @Published private(set) var groupRemaining: Int = 0
    @Published private(set) var sessionRemaining: Int = 0
    @Published private(set) var currentGroupIndex: Int = 0

    private var timer: Timer?
    private var settings: BreathSettings = .default
    private var sessionStart: Date = Date()
    private var sessionTotalSeconds: Int = 0
    private var onComplete: ((TrainingLog) -> Void)?

    func start(settings: BreathSettings, onComplete: @escaping (TrainingLog) -> Void) {
        guard !isRunning else { return }
        self.settings = settings
        self.onComplete = onComplete

        let groupSeconds = max(1, settings.groupDurationMinutes) * 60
        let totalSeconds = groupSeconds * max(1, settings.groupCount)

        sessionStart = Date()
        sessionTotalSeconds = totalSeconds

        currentGroupIndex = 1
        groupRemaining = groupSeconds
        sessionRemaining = totalSeconds
        phase = .inhale
        phaseRemaining = max(1, settings.inhaleSeconds)

        isRunning = true
        playCue(for: .inhale)

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop(completed: Bool = false) {
        guard isRunning else { return }
        timer?.invalidate()
        timer = nil
        isRunning = false
        SoundManager.shared.stop()

        let log = TrainingLog(
            startDate: sessionStart,
            durationSeconds: sessionTotalSeconds - sessionRemaining,
            groupCount: settings.groupCount,
            inhaleSeconds: settings.inhaleSeconds,
            exhaleSeconds: settings.exhaleSeconds,
            completed: completed
        )
        onComplete?(log)
        onComplete = nil
    }

    private func tick() {
        guard isRunning else { return }

        if sessionRemaining <= 0 {
            stop(completed: true)
            return
        }

        sessionRemaining -= 1
        groupRemaining -= 1

        if phaseRemaining > 1 {
            phaseRemaining -= 1
        } else {
            switch phase {
            case .inhale:
                phase = .exhale
                phaseRemaining = max(1, settings.exhaleSeconds)
                playCue(for: .exhale)
            case .exhale:
                phase = .inhale
                phaseRemaining = max(1, settings.inhaleSeconds)
                playCue(for: .inhale)
            }
        }

        if groupRemaining <= 0 {
            currentGroupIndex += 1
            if currentGroupIndex > max(1, settings.groupCount) {
                stop(completed: true)
            } else {
                groupRemaining = max(1, settings.groupDurationMinutes) * 60
            }
        }
    }

    private func playCue(for phase: BreathPhase) {
        SoundManager.shared.startPhaseSound(
            profile: settings.soundProfile,
            phase: phase,
            durationSeconds: phase == .inhale ? settings.inhaleSeconds : settings.exhaleSeconds
        )

        if settings.hapticsEnabled {
            SoundManager.shared.haptic()
        }
    }
}
