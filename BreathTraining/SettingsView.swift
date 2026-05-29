import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

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
                        .foregroundColor(ZenPalette.textPrimary)
                    } header: {
                        Text("THEME")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(ZenPalette.textMuted)
                            .tracking(1)
                    }

                    Section {
                        Button(role: .destructive) {
                            settingsStore.reset()
                        } label: {
                            Text("Reset Settings")
                        }
                    } header: {
                        Text("PREFERENCES")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(ZenPalette.textMuted)
                            .tracking(1)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(ZenPalette.gold)
    }

    private var bindingTheme: Binding<AppTheme> {
        Binding<AppTheme>(
            get: { settingsStore.settings.theme },
            set: { newValue in settingsStore.settings.theme = newValue }
        )
    }
}
