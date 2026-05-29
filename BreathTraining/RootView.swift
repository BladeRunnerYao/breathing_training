import SwiftUI

struct RootView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @Environment(\.colorScheme) private var systemScheme

    private var resolvedColorScheme: ColorScheme? {
        switch settingsStore.settings.theme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    private var zenColors: ZenColors {
        switch settingsStore.settings.theme {
        case .dark: return .dark
        case .light: return .light
        case .system: return systemScheme == .dark ? .dark : .light
        }
    }

    var body: some View {
        TabView {
            TrainingView()
                .tabItem {
                    Label("Train", systemImage: "lungs")
                }

            LogView()
                .tabItem {
                    Label("Log", systemImage: "calendar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .environment(\.zen, zenColors)
        .tint(zenColors.gold)
        .preferredColorScheme(resolvedColorScheme)
    }
}
