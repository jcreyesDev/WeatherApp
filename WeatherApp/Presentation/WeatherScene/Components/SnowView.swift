import SwiftUI

private let snowStartTime = Date()

struct SnowView: View {
    
    let condition: WeatherCondition
    @State private var flakes: [Flake] = []

    private var isActive: Bool {
        condition.contains(.snowy)
    }

    var body: some View {
        GeometryReader { geo in
            if isActive && !flakes.isEmpty {
                TimelineView(.animation(minimumInterval: 1/60, paused: !isActive)) { timeline in
                    SnowCanvas(
                        date: timeline.date,
                        width: geo.size.width,
                        height: geo.size.height,
                        flakes: flakes
                    )
                }
            }
        }
        .onAppear {
            initFlakes()
        }
        .onChange(of: condition) {
            if flakes.isEmpty {
                initFlakes()
            }
        }
        .animation(.easeInOut(duration: 0.8), value: isActive)
    }

    private func initFlakes() {
        guard flakes.isEmpty else { return }
        flakes = (0..<70).map { _ in
            Flake(
                x: CGFloat.random(in: 0...1),
                startY: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 3...10),
                speed: CGFloat.random(in: 0.15...0.25),
                driftSpeed: CGFloat.random(in: 0.15...0.45),
                driftAmount: CGFloat.random(in: -0.025...0.025),
                opacity: Double.random(in: 0.5...1.0),
                phaseOffset: CGFloat.random(in: 0...(.pi * 2))
            )
        }
    }
}

// MARK: - Snow Canvas

private struct SnowCanvas: View {
    
    let date: Date
    let width: CGFloat
    let height: CGFloat
    let flakes: [Flake]

    var body: some View {
        let t = CGFloat(date.timeIntervalSince(snowStartTime))

        Canvas { context, size in
            for flake in flakes {
                let yRaw = flake.startY + t * flake.speed
                let yProgress = yRaw.truncatingRemainder(dividingBy: 1.0)
                let y = yProgress * size.height

                let xDrift = sin(t * flake.driftSpeed + flake.phaseOffset) * flake.driftAmount
                var xNorm = flake.x + xDrift
                xNorm = xNorm - floor(xNorm)
                let x = xNorm * size.width

                let r = flake.size / 2
                let center = CGPoint(x: x, y: y)

                context.drawLayer { ctx in
                    // 6 brazos principales
                    for i in 0..<6 {
                        let angle = CGFloat(i) * .pi / 3
                        let tipX = center.x + cos(angle) * r
                        let tipY = center.y + sin(angle) * r

                        var arm = Path()
                        arm.move(to: center)
                        arm.addLine(to: CGPoint(x: tipX, y: tipY))
                        ctx.stroke(
                            arm,
                            with: .color(.white.opacity(flake.opacity)),
                            lineWidth: flake.size * 0.18
                        )

                        // Ramitas en cada brazo
                        let mid1X = center.x + cos(angle) * r * 0.45
                        let mid1Y = center.y + sin(angle) * r * 0.45
                        let mid2X = center.x + cos(angle) * r * 0.70
                        let mid2Y = center.y + sin(angle) * r * 0.70

                        for sign: CGFloat in [-1, 1] {
                            let branchAngle = angle + sign * .pi / 3
                            let branchLen = r * 0.30

                            var b1 = Path()
                            b1.move(to: CGPoint(x: mid1X, y: mid1Y))
                            b1.addLine(to: CGPoint(
                                x: mid1X + cos(branchAngle) * branchLen,
                                y: mid1Y + sin(branchAngle) * branchLen
                            ))
                            ctx.stroke(
                                b1,
                                with: .color(.white.opacity(flake.opacity * 0.8)),
                                lineWidth: flake.size * 0.12
                            )

                            var b2 = Path()
                            b2.move(to: CGPoint(x: mid2X, y: mid2Y))
                            b2.addLine(to: CGPoint(
                                x: mid2X + cos(branchAngle) * branchLen * 0.7,
                                y: mid2Y + sin(branchAngle) * branchLen * 0.7
                            ))
                            ctx.stroke(
                                b2,
                                with: .color(.white.opacity(flake.opacity * 0.6)),
                                lineWidth: flake.size * 0.10
                            )
                        }
                    }

                    // Centro
                    let dotRect = CGRect(
                        x: center.x - r * 0.15,
                        y: center.y - r * 0.15,
                        width: r * 0.30,
                        height: r * 0.30
                    )
                    ctx.fill(
                        Path(ellipseIn: dotRect),
                        with: .color(.white.opacity(flake.opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Flake Model

private struct Flake {
    let x: CGFloat
    let startY: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let driftSpeed: CGFloat
    let driftAmount: CGFloat
    let opacity: Double
    let phaseOffset: CGFloat
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "a8c0d6").ignoresSafeArea()
        SnowView(condition: .heavySnow)
    }
}
