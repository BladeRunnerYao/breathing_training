import Foundation

enum BreathPhase: String, Codable {
    case inhale
    case exhale
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

enum BreathSoundProfile: String, CaseIterable, Identifiable, Codable {
    case singingBowl

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .singingBowl: return "Singing Bowl"
        }
    }

    var inhaleResourceName: String {
        switch self {
        case .singingBowl: return "freesound_community-singing-bowl-hit-3-33366"
        }
    }

    var exhaleResourceName: String {
        switch self {
        case .singingBowl: return "freesound_community-singing-bowl-hit-3-33366"
        }
    }
}

struct BreathSettings: Codable, Equatable {
    var inhaleSeconds: Int
    var exhaleSeconds: Int
    var groupCount: Int
    var groupDurationMinutes: Int
    var soundProfile: BreathSoundProfile
    var hapticsEnabled: Bool
    var theme: AppTheme

    static let `default` = BreathSettings(
        inhaleSeconds: 4,
        exhaleSeconds: 6,
        groupCount: 1,
        groupDurationMinutes: 5,
        soundProfile: .singingBowl,
        hapticsEnabled: true,
        theme: .dark
    )
}

struct TrainingLog: Codable, Identifiable, Equatable {
    let id: UUID
    let startDate: Date
    let durationSeconds: Int
    let groupCount: Int
    let inhaleSeconds: Int
    let exhaleSeconds: Int
    let completed: Bool

    init(
        id: UUID = UUID(),
        startDate: Date,
        durationSeconds: Int,
        groupCount: Int,
        inhaleSeconds: Int,
        exhaleSeconds: Int,
        completed: Bool
    ) {
        self.id = id
        self.startDate = startDate
        self.durationSeconds = durationSeconds
        self.groupCount = groupCount
        self.inhaleSeconds = inhaleSeconds
        self.exhaleSeconds = exhaleSeconds
        self.completed = completed
    }
}
