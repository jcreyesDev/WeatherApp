import SwiftUI

struct ShowcaseCardView: View {
    
    let title: String
    let condition: WeatherCondition

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Mini escena animada — no intercepta taps
            ZStack {
                SkyBackgroundView(condition: condition)
                StarsView(condition: condition)
                MoonView(condition: condition)
                SunView(condition: condition)
                CloudsView(condition: condition)
                RainView(condition: condition)
                SnowView(condition: condition)
                HailView(condition: condition)
                FogView(condition: condition)
            }
            .allowsHitTesting(false)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Gradiente
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Título
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
                .allowsHitTesting(false)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ShowcaseCardView(title: "☀️ Soleado", condition: .sunnyDay)
            ShowcaseCardView(title: "⛈ Tormenta", condition: .thunderstorm)
            ShowcaseCardView(title: "🌨 Nevada", condition: .heavySnow)
            ShowcaseCardView(title: "🌙 Noche", condition: .clearNight)
        }
        .padding()
    }
}
