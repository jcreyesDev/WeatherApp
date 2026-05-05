import SwiftUI

private let rainStartTime = Date()

struct RainView: View {
    
    let condition: WeatherCondition

    private var isActive: Bool {
        condition.contains(.rainy) || condition.contains(.drizzle)
    }

    private var dropCount: Int {
        if condition.contains(.rainy)   { return 80 }
        if condition.contains(.drizzle) { return 45 }
        return 0
    }

    private var dropColor: Color {
        condition.contains(.night) ? Color(hex: "7fa8c8") : Color(hex: "a8d0e8")
    }

    var body: some View {
        GeometryReader { geo in
            if isActive {
                // Gotas — Canvas + TimelineView
                TimelineView(.animation(minimumInterval: 1/60, paused: !isActive)) { timeline in
                    RainCanvas(
                        date: timeline.date,
                        width: geo.size.width,
                        height: geo.size.height,
                        dropCount: dropCount,
                        color: dropColor,
                        isNight: condition.contains(.night),
                        isWindy: condition.contains(.windy)
                    )
                }

                // Splash — mantenemos el approach original
                ForEach(splashes) { splash in
                    SplashView(
                        splash: splash,
                        width: geo.size.width,
                        height: geo.size.height,
                        color: dropColor
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isActive)
    }

    private let splashes: [SplashDrop] = (0..<24).map { _ in
        SplashDrop(
            x: CGFloat.random(in: 0.05...0.95),
            interval: Double.random(in: 0.6...1.4),
            yOffset: CGFloat.random(in: -20...0),
            angle: Double.random(in: -8...18)
        )
    }
}

// MARK: - Rain Canvas

private struct RainCanvas: View {

    let date: Date
    let width: CGFloat
    let height: CGFloat
    let dropCount: Int
    let color: Color
    let isNight: Bool
    let isWindy: Bool

    private struct RainDrop {
        let x: CGFloat
        let startY: CGFloat
        let length: CGFloat
        let strokeWidth: CGFloat
        let speed: CGFloat
        let opacity: Double
        let angle: Double
        let layer: Int  // 0 back, 1 mid, 2 front
    }

    private let drops: [RainDrop] = {
        var result: [RainDrop] = []

        // Capa trasera
        for _ in 0..<40 {
            result.append(RainDrop(
                x: CGFloat.random(in: 0...1),
                startY: CGFloat.random(in: 0...1),
                length: CGFloat.random(in: 8...16),
                strokeWidth: 0.8,
                speed: CGFloat.random(in: 0.55...0.75),
                opacity: Double.random(in: 0.2...0.35),
                angle: Double.random(in: -2...14),
                layer: 0
            ))
        }

        // Capa media
        for _ in 0..<40 {
            result.append(RainDrop(
                x: CGFloat.random(in: 0...1),
                startY: CGFloat.random(in: 0...1),
                length: CGFloat.random(in: 16...26),
                strokeWidth: 1.2,
                speed: CGFloat.random(in: 0.40...0.55),
                opacity: Double.random(in: 0.35...0.55),
                angle: Double.random(in: 0...18),
                layer: 1
            ))
        }

        // Capa frontal
        for _ in 0..<25 {
            result.append(RainDrop(
                x: CGFloat.random(in: 0...1),
                startY: CGFloat.random(in: 0...1),
                length: CGFloat.random(in: 28...42),
                strokeWidth: 1.8,
                speed: CGFloat.random(in: 0.25...0.40),
                opacity: Double.random(in: 0.6...0.85),
                angle: Double.random(in: 2...22),
                layer: 2
            ))
        }

        return result
    }()

    var body: some View {
        let t = CGFloat(date.timeIntervalSince(rainStartTime))

        Canvas { context, size in
            let visibleDrops = Array(drops.prefix(dropCount))

            for drop in visibleDrops {
                let yRaw = drop.startY + t * drop.speed
                let yProgress = yRaw.truncatingRemainder(dividingBy: 1.0)
                let y = yProgress * size.height

                let angleRad = drop.angle * .pi / 180
                let dx = sin(angleRad) * drop.length
                let dy = cos(angleRad) * drop.length

                let x = drop.x * size.width

                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x + dx, y: y + dy))

                context.stroke(
                    path,
                    with: .color(color.opacity(drop.opacity)),
                    style: StrokeStyle(
                        lineWidth: drop.strokeWidth,
                        lineCap: .round
                    )
                )
            }
        }
    }
}

// MARK: - Splash

fileprivate struct SplashDrop: Identifiable {
    let id = UUID()
    let x: CGFloat
    let interval: Double
    let yOffset: CGFloat
    let angle: Double
}

fileprivate struct SplashView: View {
    
    let splash: SplashDrop
    let width: CGFloat
    let height: CGFloat
    let color: Color

    @State private var leftOpacity: Double = 0
    @State private var rightOpacity: Double = 0
    @State private var leftOffset: CGSize = .zero
    @State private var rightOffset: CGSize = .zero

    private var bottomY: CGFloat { height - 12 + splash.yOffset }

    var body: some View {
        ZStack {
            Capsule()
                .fill(color.opacity(leftOpacity))
                .frame(width: 1.2, height: 7)
                .rotationEffect(.degrees(-40 - splash.angle))
                .offset(leftOffset)

            Capsule()
                .fill(color.opacity(rightOpacity))
                .frame(width: 1.2, height: 7)
                .rotationEffect(.degrees(40 - splash.angle))
                .offset(rightOffset)
        }
        .position(x: splash.x * width, y: bottomY)
        .onAppear {
            startSplash()
        }
    }

    private func startSplash() {
        leftOpacity = 0
        rightOpacity = 0
        leftOffset = .zero
        rightOffset = .zero

        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...splash.interval)) {
            withAnimation(.easeOut(duration: 0.25)) {
                leftOpacity = 0.7
                rightOpacity = 0.7
                leftOffset = CGSize(width: -5, height: -6)
                rightOffset = CGSize(width: 5, height: -6)
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.2)) {
                leftOpacity = 0
                rightOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + splash.interval) {
                startSplash()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "2c3e50").ignoresSafeArea()
        RainView(condition: .thunderstorm)
    }
}
