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
        }
    }
}
