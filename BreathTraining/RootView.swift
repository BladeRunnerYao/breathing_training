import SwiftUI

struct RootView: View {
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
        .tint(CalmPalette.accent)
    }
}
