import SwiftUI

struct ZenPalette {
    // Backgrounds
    static let backgroundDeep = Color(red: 0.10, green: 0.10, blue: 0.18)
    static let backgroundMid = Color(red: 0.09, green: 0.13, blue: 0.24)
    static let backgroundSurface = Color(red: 0.12, green: 0.16, blue: 0.22)

    // Accents
    static let gold = Color(red: 0.83, green: 0.65, blue: 0.45)
    static let goldLight = Color(red: 0.91, green: 0.78, blue: 0.60)
    static let goldMuted = Color(red: 0.65, green: 0.49, blue: 0.32)

    // Breath phases
    static let inhale = Color(red: 0.48, green: 0.65, blue: 0.60)
    static let exhale = Color(red: 0.72, green: 0.66, blue: 0.79)

    // Text
    static let textPrimary = Color(red: 0.94, green: 0.93, blue: 0.90)
    static let textSecondary = Color(red: 0.61, green: 0.64, blue: 0.69)
    static let textMuted = Color(red: 0.42, green: 0.45, blue: 0.50)

    // Utility
    static let danger = Color(red: 0.79, green: 0.44, blue: 0.44)
    static let divider = Color(red: 0.18, green: 0.22, blue: 0.28)
}

struct ZenBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ZenPalette.backgroundDeep,
                ZenPalette.backgroundMid
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension View {
    func zenCard() -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ZenPalette.backgroundSurface.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ZenPalette.divider, lineWidth: 0.5)
                    )
            )
    }
}
