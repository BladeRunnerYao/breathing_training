import Foundation
import Combine

final class SettingsStore: ObservableObject {
    @Published var settings: BreathSettings {
        didSet { save(settings) }
    }

    private let storageKey = "breath.training.settings"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let loaded = try? JSONDecoder().decode(BreathSettings.self, from: data) {
            self.settings = loaded
        } else {
            self.settings = .default
        }
    }

    func reset() {
        settings = .default
    }

    private func save(_ settings: BreathSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
