import SwiftUI

@main
struct BreathTrainingApp: App {
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var logStore = LogStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settingsStore)
                .environmentObject(logStore)
                .preferredColorScheme(colorScheme(for: settingsStore.settings.theme))
        }
    }

    private func colorScheme(for theme: AppTheme) -> ColorScheme? {
        switch theme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
