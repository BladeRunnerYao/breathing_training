import SwiftUI

struct CalmPalette {
    static let backgroundTop = Color(red: 0.90, green: 0.98, blue: 0.97)
    static let backgroundBottom = Color(red: 0.72, green: 0.92, blue: 0.90)
    static let accent = Color(red: 0.10, green: 0.62, blue: 0.58)
    static let inhale = Color(red: 0.14, green: 0.70, blue: 0.66)
    static let exhale = Color(red: 0.08, green: 0.52, blue: 0.50)
}

struct CalmBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [CalmPalette.backgroundTop, CalmPalette.backgroundBottom]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

extension View {
    func softCard() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
            )
    }
}
