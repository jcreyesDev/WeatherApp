import SwiftUI

struct SunView: View {
    
    let condition: WeatherCondition

    @State private var rotate = false
    @State private var pulse = false

    // Ahora solo reacciona a .sunny
    private var isVisible: Bool {
        condition.contains(.sunny)
    }

    private var isGolden: Bool {
        condition.contains(.dusk) || condition.contains(.dawn)
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Halo exterior
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (isGolden ? Color(hex: "FF8C00") : Color(hex: "FFD700")).opacity(pulse ? 0.18 : 0.10),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: pulse ? 110 : 90
                        )
                    )
                    .frame(width: 220, height: 220)
                    .blur(radius: 20)

                // Halo medio
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (isGolden ? Color(hex: "FFA500") : Color(hex: "FFE44D")).opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 8)

                // Rayos con variedad
                ForEach(0..<16, id: \.self) { i in
                    let isLong = i % 2 == 0
                    let length: CGFloat = isLong
                        ? CGFloat.random(in: 28...38)
                        : CGFloat.random(in: 14...22)
                    let width: CGFloat = isLong
                        ? CGFloat.random(in: 2...3.5)
                        : CGFloat.random(in: 1...2)
                    let distance: CGFloat = isLong
                        ? (pulse ? 58 : 54)
                        : (pulse ? 48 : 44)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    (isGolden ? Color(hex: "FFA500") : Color(hex: "FFE680")).opacity(isLong ? 0.9 : 0.6),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: length, height: width)
                        .offset(x: distance)
                        .rotationEffect(.degrees(Double(i) * 22.5 + (rotate ? 360 : 0)))
                }

                // Cuerpo del sol
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                isGolden ? Color(hex: "FF8C00") : Color(hex: "FFD700"),
                                isGolden ? Color(hex: "FF6600") : Color(hex: "FFA500")
                            ],
                            center: UnitPoint(x: 0.35, y: 0.35),
                            startRadius: 0,
                            endRadius: 38
                        )
                    )
                    .frame(width: 72, height: 72)
                    .blur(radius: 1.5)
            }
            .position(
                x: geo.size.width * 0.75,
                y: isGolden ? geo.size.height * 0.75 : geo.size.height * 0.22
            )
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 1.2), value: isVisible)
        }
        .onAppear {
            guard isVisible else { return }
            withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
                rotate = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .onChange(of: isVisible) {
            if isVisible {
                withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
                    rotate = true
                }
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    rotate = false
                    pulse = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "87ceeb").ignoresSafeArea()
        SunView(condition: .sunnyDay)
    }
}
