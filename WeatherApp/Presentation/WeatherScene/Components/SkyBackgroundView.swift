import SwiftUI

struct SkyBackgroundView: View {
    
    let condition: WeatherCondition

    var body: some View {
        LinearGradient(
            colors: skyColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.5), value: condition)
    }

    // MARK: - Private

    private var skyColors: [Color] {
        // Noche
        if condition.contains(.night) && condition.contains(.denseClouds) {
            return [Color(hex: "0a0a1a"), Color(hex: "1a1a2e"), Color(hex: "16213e")]
        }
        if condition.contains(.night) && condition.contains(.cloudy) {
            return [Color(hex: "1a1a2e"), Color(hex: "2d2d44"), Color(hex: "3d3d5c")]
        }
        if condition.contains(.night) {
            return [Color(hex: "0d1b2a"), Color(hex: "1b2d4a"), Color(hex: "2c4a6e")]
        }

        // Amanecer
        if condition.contains(.dawn) {
            return [
                Color(hex: "1a1a2e"),
                Color(hex: "6B3A6B"),
                Color(hex: "FF6B35"),
                Color(hex: "FFD700"),
                Color(hex: "FFF4B3")
            ]
        }

        // Ocaso
        if condition.contains(.dusk) {
            return [
                Color(hex: "1a1a2e"),
                Color(hex: "8B4513"),
                Color(hex: "FF6B35"),
                Color(hex: "FFD700"),
                Color(hex: "FFF4B3")
            ]
        }

        // Día con nubes densas
        if condition.contains(.denseClouds) {
            return [Color(hex: "2c3e50"), Color(hex: "4a5568"), Color(hex: "718096")]
        }

        // Día con niebla
        if condition.contains(.foggy) {
            return [Color(hex: "a8b5c8"), Color(hex: "c8d3de"), Color(hex: "e8edf2")]
        }

        // Día nublado con lluvia
        if condition.contains(.cloudy) && (condition.contains(.rainy) || condition.contains(.drizzle)) {
            return [Color(hex: "4a5568"), Color(hex: "718096"), Color(hex: "a0aec0")]
        }

        // Día nublado
        if condition.contains(.cloudy) {
            return [Color(hex: "6b8cae"), Color(hex: "8fb4d0"), Color(hex: "b8d4e8"), Color(hex: "ddeef8")]
        }

        // Nieve
        if condition.contains(.snowy) {
            return [Color(hex: "7896b5"), Color(hex: "a8c0d6"), Color(hex: "d0e4f0"), Color(hex: "eef6ff")]
        }

        // Día despejado soleado
        return [Color(hex: "0a84ff"), Color(hex: "1e90ff"), Color(hex: "87ceeb"), Color(hex: "b0e2ff")]
    }
}

// MARK: - Preview

#Preview {
    SkyBackgroundView(condition: .sunnyDay)
}
