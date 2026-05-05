import SwiftUI

struct StarsView: View {
    
    let condition: WeatherCondition

    fileprivate struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let delay: Double
        let baseOpacity: Double
        let twinkleDuration: Double
        let type: StarType
    }

    fileprivate enum StarType {
        case dot
        case cross
        case bright
    }

    private let stars: [Star] = (0..<180).map { i in
        let type: StarType
        if i < 6 {
            type = .bright
        } else if i < 25 {
            type = .cross
        } else {
            type = .dot
        }
        return Star(
            x: CGFloat.random(in: 0.02...0.98),
            y: CGFloat.random(in: 0...0.95),
            size: type == .bright
                ? CGFloat.random(in: 3.0...4.5)
                : type == .cross
                    ? CGFloat.random(in: 1.8...3.0)
                    : CGFloat.random(in: 0.8...2.0),
            delay: Double.random(in: 0...6),
            baseOpacity: Double.random(in: 0.5...1.0),
            twinkleDuration: Double.random(in: 2.0...5.5),
            type: type
        )
    }

    // Ahora solo reacciona a .stars
    private var isVisible: Bool {
        condition.contains(.stars)
    }

    // Se atenúa si hay nubes
    private var cloudDim: Double {
        condition.contains(.cloudy) ? 0.35 : 1.0
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ForEach(stars) { star in
                starView(star: star, geo: geo)
            }
        }
        .drawingGroup()
        .opacity(isVisible ? cloudDim : 0)
        .animation(.easeInOut(duration: 1.5), value: isVisible)
    }

    // MARK: - Star Views

    @ViewBuilder
    private func starView(star: Star, geo: GeometryProxy) -> some View {
        switch star.type {
        case .dot:
            DotStarView(star: star)
                .position(x: star.x * geo.size.width, y: star.y * geo.size.height)

        case .cross:
            CrossStarView(star: star)
                .position(x: star.x * geo.size.width, y: star.y * geo.size.height)

        case .bright:
            BrightStarView(star: star)
                .position(x: star.x * geo.size.width, y: star.y * geo.size.height)
        }
    }
}

// MARK: - Dot Star

private struct DotStarView: View {
    
    let star: StarsView.Star
    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: star.size, height: star.size)
            .opacity(opacity)
            .onAppear {
                opacity = star.baseOpacity * 0.4
                withAnimation(
                    .easeInOut(duration: star.twinkleDuration)
                    .delay(star.delay)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = star.baseOpacity
                }
            }
    }
}

// MARK: - Cross Star

private struct CrossStarView: View {
    
    let star: StarsView.Star
    @State private var opacity: Double = 0
    @State private var rayScale: CGFloat = 0.6

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: star.size, height: star.size)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.7), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: star.size * 2.8, height: star.size * 0.35)
                .scaleEffect(x: rayScale, y: 1)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.7), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: star.size * 0.35, height: star.size * 2.8)
                .scaleEffect(x: 1, y: rayScale)
        }
        .opacity(opacity)
        .onAppear {
            opacity = star.baseOpacity * 0.35
            withAnimation(
                .easeInOut(duration: star.twinkleDuration)
                .delay(star.delay)
                .repeatForever(autoreverses: true)
            ) {
                opacity = star.baseOpacity
                rayScale = 1.0
            }
        }
    }
}

// MARK: - Bright Star

private struct BrightStarView: View {
    
    let star: StarsView.Star
    @State private var opacity: Double = 0
    @State private var glowScale: CGFloat = 0.8
    @State private var rayScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.20), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: star.size * 3
                    )
                )
                .frame(width: star.size * 6, height: star.size * 6)
                .scaleEffect(glowScale)
                .blur(radius: 2)

            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.65), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: star.size * 3.8, height: star.size * 0.30)
                    .scaleEffect(x: rayScale, y: 1)
                    .rotationEffect(.degrees(Double(i) * 45))
            }

            Circle()
                .fill(Color.white)
                .frame(width: star.size, height: star.size)
                .blur(radius: 0.4)
        }
        .opacity(opacity)
        .onAppear {
            opacity = star.baseOpacity * 0.3
            withAnimation(
                .easeInOut(duration: star.twinkleDuration)
                .delay(star.delay)
                .repeatForever(autoreverses: true)
            ) {
                opacity = star.baseOpacity
                glowScale = 1.2
                rayScale = 1.0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "0d1b2a").ignoresSafeArea()
        StarsView(condition: .clearNight)
    }
}
