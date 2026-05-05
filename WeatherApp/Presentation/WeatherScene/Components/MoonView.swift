import SwiftUI

struct MoonView: View {
    
    let condition: WeatherCondition

    @State private var glowPulse = false
    @State private var shimmer = false

    // Ahora solo reacciona a .moon
    private var isVisible: Bool {
        condition.contains(.moon)
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Halo exterior difuso
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "FFF8DC").opacity(glowPulse ? 0.15 : 0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: glowPulse ? 120 : 90
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 22)

                // Halo medio
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "E8E0C0").opacity(0.30),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 10)

                // Cuerpo de la luna
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.98),
                                Color(hex: "FFF8DC"),
                                Color(hex: "EEE0A0")
                            ],
                            center: UnitPoint(x: 0.35, y: 0.30),
                            startRadius: 0,
                            endRadius: 42
                        )
                    )
                    .frame(width: 72, height: 72)
                    .blur(radius: 1.2)
                    .overlay {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "D4C88A").opacity(0.45))
                                .frame(width: 14, height: 14)
                                .offset(x: 10, y: -8)
                                .blur(radius: 1.5)
                            Circle()
                                .fill(Color(hex: "D4C88A").opacity(0.35))
                                .frame(width: 9, height: 9)
                                .offset(x: -12, y: 10)
                                .blur(radius: 1.2)
                            Circle()
                                .fill(Color(hex: "D4C88A").opacity(0.30))
                                .frame(width: 6, height: 6)
                                .offset(x: 4, y: 16)
                                .blur(radius: 1.0)
                            Circle()
                                .fill(Color(hex: "D4C88A").opacity(0.25))
                                .frame(width: 5, height: 5)
                                .offset(x: -6, y: -14)
                                .blur(radius: 0.8)
                        }
                    }

                // Brillo superior izquierdo
                Circle()
                    .fill(Color.white.opacity(shimmer ? 0.35 : 0.20))
                    .frame(width: 22, height: 22)
                    .blur(radius: 6)
                    .offset(x: -16, y: -16)
            }
            .position(x: geo.size.width * 0.76, y: geo.size.height * 0.22)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 1.2), value: isVisible)
        }
        .onAppear {
            guard isVisible else { return }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
        .onChange(of: isVisible) {
            if isVisible {
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    shimmer = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    glowPulse = false
                    shimmer = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "0d1b2a").ignoresSafeArea()
        MoonView(condition: .clearNight)
    }
}
