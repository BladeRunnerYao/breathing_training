import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @Environment(\.zen) private var zen

    var body: some View {
        NavigationStack {
            ZStack {
                ZenBackground()
                Form {
                    Section {
                        Picker("Appearance", selection: bindingTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                        .foregroundColor(zen.textPrimary)
                    } header: {
                        Text("THEME")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(zen.textMuted)
                            .tracking(1)
                    }

                    Section {
                        Button {
                            settingsStore.reset()
                        } label: {
                            Text("Reset Settings")
                                .foregroundColor(zen.goldMuted)
                        }
                    } header: {
                        Text("PREFERENCES")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(zen.textMuted)
                            .tracking(1)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")

        }
        .tint(zen.gold)
    }

    private var bindingTheme: Binding<AppTheme> {
        Binding<AppTheme>(
            get: { settingsStore.settings.theme },
            set: { newValue in settingsStore.settings.theme = newValue }
        )
    }
}
