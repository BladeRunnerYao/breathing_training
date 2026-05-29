import SwiftUI

// MARK: - Static Color Palettes

struct ZenPalette {
    // MARK: Dark Theme
    struct Dark {
        static let backgroundDeep = Color(red: 0.10, green: 0.10, blue: 0.18)
        static let backgroundMid = Color(red: 0.09, green: 0.13, blue: 0.24)
        static let backgroundSurface = Color(red: 0.12, green: 0.16, blue: 0.22)

        static let gold = Color(red: 0.83, green: 0.65, blue: 0.45)
        static let goldLight = Color(red: 0.91, green: 0.78, blue: 0.60)
        static let goldMuted = Color(red: 0.65, green: 0.49, blue: 0.32)

        static let inhale = Color(red: 0.48, green: 0.65, blue: 0.60)
        static let exhale = Color(red: 0.72, green: 0.66, blue: 0.79)

        static let textPrimary = Color(red: 0.94, green: 0.93, blue: 0.90)
        static let textSecondary = Color(red: 0.61, green: 0.64, blue: 0.69)
        static let textMuted = Color(red: 0.42, green: 0.45, blue: 0.50)

        static let danger = Color(red: 0.79, green: 0.44, blue: 0.44)
        static let divider = Color(red: 0.18, green: 0.22, blue: 0.28)
    }

    // MARK: Light Theme (Zen / Washi paper inspired)
    struct Light {
        static let backgroundDeep = Color(red: 0.96, green: 0.94, blue: 0.91)
        static let backgroundMid = Color(red: 0.93, green: 0.90, blue: 0.86)
        static let backgroundSurface = Color(red: 0.98, green: 0.96, blue: 0.93)

        static let gold = Color(red: 0.65, green: 0.49, blue: 0.32)
        static let goldLight = Color(red: 0.76, green: 0.60, blue: 0.42)
        static let goldMuted = Color(red: 0.55, green: 0.42, blue: 0.28)

        static let inhale = Color(red: 0.30, green: 0.50, blue: 0.45)
        static let exhale = Color(red: 0.50, green: 0.42, blue: 0.60)

        static let textPrimary = Color(red: 0.18, green: 0.16, blue: 0.14)
        static let textSecondary = Color(red: 0.40, green: 0.38, blue: 0.35)
        static let textMuted = Color(red: 0.58, green: 0.55, blue: 0.52)

        static let danger = Color(red: 0.72, green: 0.38, blue: 0.38)
        static let divider = Color(red: 0.85, green: 0.82, blue: 0.78)
    }
}

// MARK: - Adaptive Colors

struct ZenColors {
    let backgroundDeep: Color
    let backgroundMid: Color
    let backgroundSurface: Color
    let gold: Color
    let goldLight: Color
    let goldMuted: Color
    let inhale: Color
    let exhale: Color
    let textPrimary: Color
    let textSecondary: Color
    let textMuted: Color
    let danger: Color
    let divider: Color

    static let dark = ZenColors(
        backgroundDeep: ZenPalette.Dark.backgroundDeep,
        backgroundMid: ZenPalette.Dark.backgroundMid,
        backgroundSurface: ZenPalette.Dark.backgroundSurface,
        gold: ZenPalette.Dark.gold,
        goldLight: ZenPalette.Dark.goldLight,
        goldMuted: ZenPalette.Dark.goldMuted,
        inhale: ZenPalette.Dark.inhale,
        exhale: ZenPalette.Dark.exhale,
        textPrimary: ZenPalette.Dark.textPrimary,
        textSecondary: ZenPalette.Dark.textSecondary,
        textMuted: ZenPalette.Dark.textMuted,
        danger: ZenPalette.Dark.danger,
        divider: ZenPalette.Dark.divider
    )

    static let light = ZenColors(
        backgroundDeep: ZenPalette.Light.backgroundDeep,
        backgroundMid: ZenPalette.Light.backgroundMid,
        backgroundSurface: ZenPalette.Light.backgroundSurface,
        gold: ZenPalette.Light.gold,
        goldLight: ZenPalette.Light.goldLight,
        goldMuted: ZenPalette.Light.goldMuted,
        inhale: ZenPalette.Light.inhale,
        exhale: ZenPalette.Light.exhale,
        textPrimary: ZenPalette.Light.textPrimary,
        textSecondary: ZenPalette.Light.textSecondary,
        textMuted: ZenPalette.Light.textMuted,
        danger: ZenPalette.Light.danger,
        divider: ZenPalette.Light.divider
    )
}

// MARK: - Environment Key

private struct ZenColorsKey: EnvironmentKey {
    static let defaultValue = ZenColors.dark
}

extension EnvironmentValues {
    var zen: ZenColors {
        get { self[ZenColorsKey.self] }
        set { self[ZenColorsKey.self] = newValue }
    }
}

// MARK: - Adaptive Views

struct ZenBackground: View {
    @Environment(\.zen) private var zen

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [zen.backgroundDeep, zen.backgroundMid]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension View {
    func zenCard() -> some View {
        modifier(ZenCardModifier())
    }
}

struct ZenCardModifier: ViewModifier {
    @Environment(\.zen) private var zen

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(zen.backgroundSurface.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(zen.divider, lineWidth: 0.5)
                    )
            )
    }
}
