import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

    var body: some View {
        NavigationStack {
            ZStack {
                CalmBackground()
                Form {
                    Section(header: Text("Theme")) {
                        Picker("Appearance", selection: bindingTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                    }

                    Section(header: Text("Preferences")) {
                        Button("Reset Settings") {
                            settingsStore.reset()
                        }
                        .foregroundColor(.red)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }

    private var bindingTheme: Binding<AppTheme> {
        Binding<AppTheme>(
            get: { settingsStore.settings.theme },
            set: { newValue in settingsStore.settings.theme = newValue }
        )
    }
}
