import SwiftUI

struct EnsoBreathingView: View {
    let phase: BreathPhase
    let phaseRemaining: Int
    let phaseDuration: Int

    private var phaseColor: Color {
        phase == .inhale ? ZenPalette.inhale : ZenPalette.exhale
    }

    var body: some View {
        ZStack {
            // Ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [phaseColor.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 60,
                        endRadius: 140
                    )
                )
                .frame(width: 260, height: 260)

            // Enso ring
            Circle()
                .stroke(phaseColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 200, height: 200)
                .scaleEffect(phase == .inhale ? 1.0 : 0.85)
                .animation(.easeInOut(duration: Double(phaseDuration)), value: phase)

            // Phase text
            VStack(spacing: 8) {
                Text(phase == .inhale ? "INHALE" : "EXHALE")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .tracking(3)
                    .foregroundColor(ZenPalette.textSecondary)

                Text(formatTimer(seconds: phaseRemaining))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(ZenPalette.textPrimary)
            }
        }
    }

    private func formatTimer(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
