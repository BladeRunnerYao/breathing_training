Zen UI Refinement Plan — Phase 2
Overview
Follow-up refinements to the Zen redesign (Phase 1). Addresses layout issues, removes unnecessary elements, introduces a Zen Light theme, and softens destructive-action styling.
Scope: Purely visual/layout changes. No logic, data, or engine changes.

Issues to Fix
#	Screen	Issue	Solution
1	Train	"Breath Training" nav title wastes vertical space; session settings not fully visible without scrolling	Remove navigation title; add a small inline header or none at all
2	Log	"Training Log" nav title wastes space	Remove navigation title
3	Log	Log list below calendar looks like an ugly large rectangle in the center	Restyle as compact inline rows (no card wrapper), or remove the card container
4	Log	"Delete All Logs" button present	Remove it entirely
5	Settings	Light theme selection has no effect (app forces .preferredColorScheme(.dark))	Implement a Zen Light palette and wire up theme switching
6	Settings	"Reset Settings" button uses aggressive red color	Replace with a softer, Zen-appropriate muted color
Detailed Changes
1. TrainingView.swift — Remove Navigation Title
Current code:
.navigationTitle("Breath Training")
.toolbarColorScheme(.dark, for: .navigationBar)
Change to:
.navigationBarTitleDisplayMode(.inline)
.toolbar {
    ToolbarItem(placement: .principal) {
        EmptyView()
    }
}
This removes the large "Breath Training" title and reclaims ~60pt of vertical space. The Enso breathing circle and session info already make it obvious which screen the user is on.
Alternative (minimal inline label): If completely removing the title feels too bare, use a very small inline label:

.toolbar {
    ToolbarItem(placement: .principal) {
        Text("Breath Training")
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundColor(ZenPalette.textSecondary)
    }
}
Choose one approach. Recommended: remove entirely.
2. LogView.swift — Remove Navigation Title
Current code:
.navigationTitle("Training Log")
.toolbarColorScheme(.dark, for: .navigationBar)
Change to:
.navigationBarTitleDisplayMode(.inline)
.toolbar {
    ToolbarItem(placement: .principal) {
        EmptyView()
    }
}
The month header with chevron navigation already serves as the page header.
3. LogView.swift — Restyle Log List
Current: logList is a VStack containing a title "Sessions on May 29", log entries as cards with left gold border, and a "Delete All Logs" button — all visually heavy.
New design: Remove the wrapping card. Show sessions as a compact, elegant list directly below the calendar card. Each session is a simple row, not a card-in-card.

Replace the entire logList computed property:

private var logList: some View {
    let logs = logStore.logs(on: selectedDate)
    return VStack(alignment: .leading, spacing: 0) {
        // Date sub-header
        Text(dateTitle(selectedDate))
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(ZenPalette.textMuted)
            .tracking(1)
            .textCase(.uppercase)
            .padding(.bottom, 12)

        if logs.isEmpty {
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "leaf")
                        .font(.system(size: 28))
                        .foregroundColor(ZenPalette.textMuted.opacity(0.5))
                    Text("Rest day")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(ZenPalette.textMuted)
                }
                .padding(.vertical, 24)
                Spacer()
            }
        } else {
            ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
                VStack(spacing: 0) {
                    if index > 0 {
                        ZenPalette.divider
                            .frame(height: 0.5)
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatDuration(log.durationSeconds))
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(ZenPalette.textPrimary)
                            Text("\(log.inhaleSeconds)s in · \(log.exhaleSeconds)s out · \(log.groupCount) groups")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(ZenPalette.textSecondary)
                        }
                        Spacer()
                        Text(timeOfDay(log.startDate))
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(ZenPalette.textMuted)
                    }
                    .padding(.vertical, 12)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        logStore.delete(log: log)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
    .padding(.horizontal, 20)
}
Add helper to LogView:
private func timeOfDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}
Key design decisions:
No wrapping .zenCard() — the sessions sit directly below the calendar, separated by minimal dividers
Empty state: a leaf icon with "Rest day" (gentler than "No sessions recorded")
Each row shows duration prominently, details compactly on one line, and time-of-day right-aligned
Individual delete remains available via context menu (long press)
4. LogView.swift — Remove "Delete All Logs" Button
Already handled in change #3 above — the new logList does not include a "Delete All Logs" button. (Users can still delete individual logs via context menu, and reset everything from Settings.)
5. Light Theme — Zen Light Palette + Theme Switching
This is the largest change. Currently ZenPalette is hardcoded to dark colors, and RootView forces .preferredColorScheme(.dark).
5a. UIStyles.swift — Add Adaptive Palette
Replace the static ZenPalette struct with one that provides colors based on the current theme. Use @Environment(\.colorScheme) in views, or provide two static palettes and select at usage site.
Recommended approach: Use SwiftUI Color assets or environment-aware computed properties. Simplest implementation: two palette structs + a resolver.

struct ZenPalette {
    // MARK: - Dark Theme
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

    // MARK: - Light Theme (Zen / Washi paper inspired)
    struct Light {
        // Warm off-white, like handmade Japanese paper
        static let backgroundDeep = Color(red: 0.96, green: 0.94, blue: 0.91)    // #F5F0E8 — warm cream
        static let backgroundMid = Color(red: 0.93, green: 0.90, blue: 0.86)      // #EDE6DB — slightly darker cream
        static let backgroundSurface = Color(red: 0.98, green: 0.96, blue: 0.93)  // #FAF5EE — paper white

        // Deeper gold for contrast on light backgrounds
        static let gold = Color(red: 0.65, green: 0.49, blue: 0.32)               // #A67C52 — warm brown-gold
        static let goldLight = Color(red: 0.76, green: 0.60, blue: 0.42)          // #C2996B
        static let goldMuted = Color(red: 0.55, green: 0.42, blue: 0.28)          // #8C6B47

        // Deeper breath colors for contrast on light
        static let inhale = Color(red: 0.30, green: 0.50, blue: 0.45)             // #4D8073 — deeper sage
        static let exhale = Color(red: 0.50, green: 0.42, blue: 0.60)             // #806B99 — deeper lavender

        // Dark text on light background
        static let textPrimary = Color(red: 0.18, green: 0.16, blue: 0.14)        // #2E2924 — ink black
        static let textSecondary = Color(red: 0.40, green: 0.38, blue: 0.35)      // #666059 — warm gray
        static let textMuted = Color(red: 0.58, green: 0.55, blue: 0.52)          // #948C85 — light warm gray

        static let danger = Color(red: 0.72, green: 0.38, blue: 0.38)             // #B86161 — muted rose
        static let divider = Color(red: 0.85, green: 0.82, blue: 0.78)            // #D9D1C7 — subtle warm line
    }
}
5b. UIStyles.swift — Environment-Aware Color Accessors
Add an EnvironmentKey and view modifier approach, or simpler: a struct that resolves colors from colorScheme.
Simplest approach — a resolver struct:

struct Zen {
    let colorScheme: ColorScheme

    var backgroundDeep: Color { colorScheme == .dark ? ZenPalette.Dark.backgroundDeep : ZenPalette.Light.backgroundDeep }
    var backgroundMid: Color { colorScheme == .dark ? ZenPalette.Dark.backgroundMid : ZenPalette.Light.backgroundMid }
    var backgroundSurface: Color { colorScheme == .dark ? ZenPalette.Dark.backgroundSurface : ZenPalette.Light.backgroundSurface }

    var gold: Color { colorScheme == .dark ? ZenPalette.Dark.gold : ZenPalette.Light.gold }
    var goldLight: Color { colorScheme == .dark ? ZenPalette.Dark.goldLight : ZenPalette.Light.goldLight }
    var goldMuted: Color { colorScheme == .dark ? ZenPalette.Dark.goldMuted : ZenPalette.Light.goldMuted }

    var inhale: Color { colorScheme == .dark ? ZenPalette.Dark.inhale : ZenPalette.Light.inhale }
    var exhale: Color { colorScheme == .dark ? ZenPalette.Dark.exhale : ZenPalette.Light.exhale }

    var textPrimary: Color { colorScheme == .dark ? ZenPalette.Dark.textPrimary : ZenPalette.Light.textPrimary }
    var textSecondary: Color { colorScheme == .dark ? ZenPalette.Dark.textSecondary : ZenPalette.Light.textSecondary }
    var textMuted: Color { colorScheme == .dark ? ZenPalette.Dark.textMuted : ZenPalette.Light.textMuted }

    var danger: Color { colorScheme == .dark ? ZenPalette.Dark.danger : ZenPalette.Light.danger }
    var divider: Color { colorScheme == .dark ? ZenPalette.Dark.divider : ZenPalette.Light.divider }
}
However, this requires passing Zen into every view or reading @Environment(\.colorScheme) everywhere — which is a large refactor.
Recommended alternative — SwiftUI adaptive colors using custom EnvironmentKey:

private struct ZenColorsKey: EnvironmentKey {
    static let defaultValue = ZenColors.dark
}

extension EnvironmentValues {
    var zen: ZenColors {
        get { self[ZenColorsKey.self] }
        set { self[ZenColorsKey.self] = newValue }
    }
}

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
        backgroundDeep: Color(red: 0.10, green: 0.10, blue: 0.18),
        backgroundMid: Color(red: 0.09, green: 0.13, blue: 0.24),
        backgroundSurface: Color(red: 0.12, green: 0.16, blue: 0.22),
        gold: Color(red: 0.83, green: 0.65, blue: 0.45),
        goldLight: Color(red: 0.91, green: 0.78, blue: 0.60),
        goldMuted: Color(red: 0.65, green: 0.49, blue: 0.32),
        inhale: Color(red: 0.48, green: 0.65, blue: 0.60),
        exhale: Color(red: 0.72, green: 0.66, blue: 0.79),
        textPrimary: Color(red: 0.94, green: 0.93, blue: 0.90),
        textSecondary: Color(red: 0.61, green: 0.64, blue: 0.69),
        textMuted: Color(red: 0.42, green: 0.45, blue: 0.50),
        danger: Color(red: 0.79, green: 0.44, blue: 0.44),
        divider: Color(red: 0.18, green: 0.22, blue: 0.28)
    )

    static let light = ZenColors(
        backgroundDeep: Color(red: 0.96, green: 0.94, blue: 0.91),
        backgroundMid: Color(red: 0.93, green: 0.90, blue: 0.86),
        backgroundSurface: Color(red: 0.98, green: 0.96, blue: 0.93),
        gold: Color(red: 0.65, green: 0.49, blue: 0.32),
        goldLight: Color(red: 0.76, green: 0.60, blue: 0.42),
        goldMuted: Color(red: 0.55, green: 0.42, blue: 0.28),
        inhale: Color(red: 0.30, green: 0.50, blue: 0.45),
        exhale: Color(red: 0.50, green: 0.42, blue: 0.60),
        textPrimary: Color(red: 0.18, green: 0.16, blue: 0.14),
        textSecondary: Color(red: 0.40, green: 0.38, blue: 0.35),
        textMuted: Color(red: 0.58, green: 0.55, blue: 0.52),
        danger: Color(red: 0.72, green: 0.38, blue: 0.38),
        divider: Color(red: 0.85, green: 0.82, blue: 0.78)
    )
}
Usage in views:
@Environment(\.zen) private var zen
// Then: zen.gold, zen.textPrimary, etc.
5c. UIStyles.swift — Adaptive ZenBackground
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
5d. UIStyles.swift — Adaptive .zenCard()
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
5e. RootView.swift — Wire Up Theme Switching
Current code:
struct RootView: View {
    var body: some View {
        TabView { ... }
        .tint(ZenPalette.gold)
        .preferredColorScheme(.dark)
    }
}
Change to:
struct RootView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

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
        case .system: return .dark  // default to dark for "system" or use @Environment(\.colorScheme)
        }
    }

    var body: some View {
        TabView {
            TrainingView()
                .tabItem { Label("Train", systemImage: "lungs") }
            LogView()
                .tabItem { Label("Log", systemImage: "calendar") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .environment(\.zen, zenColors)
        .tint(zenColors.gold)
        .preferredColorScheme(resolvedColorScheme)
    }
}
For the "system" case, to properly follow the device setting:
case .system:
    // Return nil so SwiftUI follows system setting
    // For zenColors, read current system colorScheme:
Add @Environment(\.colorScheme) private var systemScheme and use it:
private var zenColors: ZenColors {
    switch settingsStore.settings.theme {
    case .dark: return .dark
    case .light: return .light
    case .system: return systemScheme == .dark ? .dark : .light
    }
}
5f. SettingsView.swift — Adaptive Toolbar Color
Current:
.toolbarColorScheme(.dark, for: .navigationBar)
Change to dynamically set based on theme:
.toolbarColorScheme(zen.backgroundDeep == ZenColors.dark.backgroundDeep ? .dark : .light, for: .navigationBar)
Or simpler: remove .toolbarColorScheme and let SwiftUI handle it based on .preferredColorScheme.
Recommended: Remove all .toolbarColorScheme(.dark, for: .navigationBar) lines from TrainingView, LogView, and SettingsView. The .preferredColorScheme() set on RootView will handle navigation bar appearance automatically.

5g. Update All Views to Use @Environment(\.zen)
Every view that currently references ZenPalette.xxx must be updated to use @Environment(\.zen) private var zen and then zen.xxx.
Files to update:

TrainingView.swift — all ZenPalette.textPrimary, ZenPalette.gold, etc.
LogView.swift — same
CalendarView.swift — same
SettingsView.swift — same
EnsoBreathingView.swift — same
Search & replace pattern:
Add @Environment(\.zen) private var zen to each view struct body
Replace ZenPalette. → zen. everywhere
Note: ZenPalette.Dark and ZenPalette.Light remain as static definitions. Only the usage sites change from ZenPalette.xxx to zen.xxx.
6. SettingsView.swift — Soften "Reset Settings" Button
Current: Uses red/danger color (aggressive for a Zen app).
Change: Use a muted earth tone — goldMuted works well. It's visible, warm, and non-aggressive.

Current code (approximate):

Section {
    Button(role: .destructive) {
        settingsStore.reset()
    } label: {
        Text("Reset Settings")
    }
} header: { ... }
Change to:
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
Remove role: .destructive so the button doesn't get auto-tinted red. Use goldMuted as the text color — it's readable on both dark and light backgrounds.
Zen Light Theme — Visual Reference
Light Theme (Washi Paper)
┌─────────────────────────────────┐
│  ░░░░░ Warm cream gradient ░░░░░│  ← #F5F0E8 → #EDE6DB
│                                 │
│     ╭─── ○ ───╮                 │  ← deeper sage/lavender ring
│     │  INHALE  │                │  ← ink-black text #2E2924
│     │   0:04   │                │
│     ╰─────────╯                 │
│                                 │
│  Remaining       Group          │
│   5m 0s          1/1            │  ← ink-black values
│                                 │
│  ┌────── Begin ──────┐          │  ← brown-gold #A67C52
│  └───────────────────┘          │
│                                 │
│  ┌─ SESSION SETTINGS ──┐       │  ← paper white card #FAF5EE
│  │  Inhale        4s   │       │  ← brown-gold values
│  │  Exhale        6s   │       │
│  │  Minutes       5m   │       │
│  │  Groups        1    │       │
│  └─────────────────────┘       │
│                                 │
│  [Train]   [Log]   [Settings]  │  ← brown-gold tint
└─────────────────────────────────┘
Implementation Checklist
Phase 1: Palette Refactor (UIStyles.swift)
Rename current ZenPalette properties into ZenPalette.Dark nested struct
Add ZenPalette.Light nested struct with all light theme colors
Create ZenColors struct with instance properties
Create ZenColorsKey environment key with defaultValue = .dark
Add EnvironmentValues.zen extension
Make ZenBackground read from @Environment(\.zen)
Convert .zenCard() to ZenCardModifier reading @Environment(\.zen)
Phase 2: Theme Wiring (RootView.swift, BreathTrainingApp.swift)
Add @EnvironmentObject private var settingsStore to RootView
Add @Environment(\.colorScheme) private var systemScheme to RootView
Compute resolvedColorScheme and zenColors from settingsStore.settings.theme
Apply .environment(\.zen, zenColors) to the TabView
Apply .preferredColorScheme(resolvedColorScheme) (nil for system)
Update .tint() to use zenColors.gold
Phase 3: Migrate Color References
TrainingView.swift: Add @Environment(\.zen) private var zen; replace all ZenPalette.xxx → zen.xxx
LogView.swift: Same migration
CalendarView.swift: Same migration
SettingsView.swift: Same migration
EnsoBreathingView.swift: Same migration
Remove all .toolbarColorScheme(.dark, for: .navigationBar) lines
Phase 4: Layout Fixes
TrainingView.swift: Remove large navigation title (use .navigationBarTitleDisplayMode(.inline) with empty principal or small text)
LogView.swift: Remove large navigation title (same approach)
LogView.swift: Restyle logList — remove .zenCard() wrapper, use compact rows with dividers, add timeOfDay helper
LogView.swift: Remove "Delete All Logs" button
Phase 5: Soften Reset Button
SettingsView.swift: Remove role: .destructive from "Reset Settings" button
Use zen.goldMuted as the button text color
Phase 6: QA
Build and run on iPhone 17 Pro simulator
Verify dark theme still looks correct
Switch to Light theme in Settings → verify cream/paper background, dark text, brown-gold accents
Switch to System theme → verify it follows device setting
Verify Training tab: no large title, all settings visible without scrolling
Verify Log tab: no large title, calendar visible, sessions styled as compact rows
Verify Settings tab: "Reset Settings" is not red, uses goldMuted color
Check text readability in both themes (all text clearly visible)
File Change Summary
File	Changes
UIStyles.swift	Major rewrite: split palette into Dark/Light, add ZenColors, ZenColorsKey, environment extension, adaptive ZenBackground and ZenCardModifier
RootView.swift	Add theme resolution logic, wire .environment(\.zen, ...), dynamic .preferredColorScheme()
TrainingView.swift	Remove nav title, replace ZenPalette.xxx → zen.xxx
LogView.swift	Remove nav title, restyle logList, remove "Delete All Logs", replace ZenPalette.xxx → zen.xxx
CalendarView.swift	Replace ZenPalette.xxx → zen.xxx
SettingsView.swift	Replace ZenPalette.xxx → zen.xxx, soften reset button, remove .toolbarColorScheme
EnsoBreathingView.swift	Replace ZenPalette.xxx → zen.xxx
BreathTrainingApp.swift	No changes needed
Models.swift	No changes needed
Contrast Ratios (Light Theme)
Element	Foreground	Background	Ratio	Pass?
Primary text	#2E2924	#F5F0E8	~12.5:1	AA ✅
Secondary text	#666059	#F5F0E8	~5.2:1	AA ✅
Gold accent	#A67C52	#F5F0E8	~3.8:1	Large text ✅
Gold on card	#A67C52	#FAF5EE	~3.5:1	Large text ✅
Muted text	#948C85	#F5F0E8	~2.8:1	Decorative only
Notes for Implementing Agent
Start with Phase 1 (UIStyles.swift) — this will temporarily break all other files because ZenPalette.xxx static references will no longer exist at the top level. That's expected; Phases 2-3 fix them.
Keep ZenPalette as a namespace — ZenPalette.Dark.gold, ZenPalette.Light.gold are the static definitions. Views use zen.gold via the environment.
The @Environment(\.zen) approach avoids passing colors as parameters. Every view in the hierarchy automatically gets the right colors.
Do not change any logic — engine, settings persistence, log storage, sound manager are untouched.
Test incrementally — build after each phase to catch compile errors early.
The light theme colors are intentionally warm — cream/paper tones, not clinical white. This maintains the Zen aesthetic across both themes.

Close
