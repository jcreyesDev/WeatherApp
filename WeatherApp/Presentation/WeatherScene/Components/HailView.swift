import SwiftUI

struct HailView: View {
    
    let condition: WeatherCondition

    fileprivate struct HailStone: Identifiable {
        let id = UUID()
        let x: CGFloat
        let size: CGFloat
        let speed: Double
        let opacity: Double
        let angle: Double
        let layer: HailLayer
    }

    fileprivate enum HailLayer {
        case back
        case mid
        case front
    }

    private let stones: [HailStone] = {
        var result: [HailStone] = []

        // Capa trasera — pequeñas y transparentes
        for _ in 0..<35 {
            result.append(HailStone(
                x: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 4...7),
                speed: Double.random(in: 0.55...0.70),
                opacity: Double.random(in: 0.25...0.45),
                angle: Double.random(in: -4...4),
                layer: .back
            ))
        }

        // Capa media
        for _ in 0..<30 {
            result.append(HailStone(
                x: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 6...10),
                speed: Double.random(in: 0.40...0.55),
                opacity: Double.random(in: 0.50...0.70),
                angle: Double.random(in: -5...5),
                layer: .mid
            ))
        }

        // Capa frontal — grandes y opacas
        for _ in 0..<20 {
            result.append(HailStone(
                x: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 10...16),
                speed: Double.random(in: 0.30...0.42),
                opacity: Double.random(in: 0.75...0.95),
                angle: Double.random(in: -6...6),
                layer: .front
            ))
        }

        return result
    }()

    private let impacts: [ImpactDrop] = (0..<22).map { _ in
        ImpactDrop(
            x: CGFloat.random(in: 0.05...0.95),
            yOffset: CGFloat.random(in: -18...0),
            interval: Double.random(in: 0.5...1.0),
            angle: Double.random(in: -10...10)
        )
    }

    private var isActive: Bool {
        condition.contains(.hailing)
    }

    private var stoneColor: Color {
        condition.contains(.night)
            ? Color(hex: "c8dff0")
            : Color.white
    }

    var body: some View {
        GeometryReader { geo in
            if isActive {
                ForEach(stones) { stone in
                    HailStoneView(
                        stone: stone,
                        width: geo.size.width,
                        height: geo.size.height,
                        color: stoneColor
                    )
                }

                ForEach(impacts) { impact in
                    ImpactView(
                        impact: impact,
                        width: geo.size.width,
                        height: geo.size.height,
                        color: stoneColor
                    )
                }
            }
        }
        .drawingGroup()
        .animation(.easeInOut(duration: 0.5), value: isActive)
    }
}

// MARK: - Hail Stone View

fileprivate struct HailStoneView: View {
    
    let stone: HailView.HailStone
    let width: CGFloat
    let height: CGFloat
    let color: Color

    @State private var yOffset: CGFloat
    @State private var started = false

    init(stone: HailView.HailStone, width: CGFloat, height: CGFloat, color: Color) {
        self.stone = stone
        self.width = width
        self.height = height
        self.color = color
        _yOffset = State(initialValue: CGFloat.random(in: 0...height))
    }

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.95),
                        color.opacity(stone.opacity)
                    ],
                    center: UnitPoint(x: 0.35, y: 0.30),
                    startRadius: 0,
                    endRadius: stone.size
                )
            )
            .frame(width: stone.size, height: stone.size)
            .overlay(
                Circle()
                    .stroke(color.opacity(stone.opacity * 0.4), lineWidth: 0.5)
            )
            .rotationEffect(.degrees(stone.angle))
            .position(x: stone.x * width, y: yOffset)
            .onAppear {
                guard !started else { return }
                started = true
                startFall()
            }
    }

    private func startFall() {
        let remaining = height + 40 - yOffset
        let totalDistance = height + 80
        let adjustedSpeed = stone.speed * Double(remaining / totalDistance)

        withAnimation(.linear(duration: adjustedSpeed)) {
            yOffset = height + 40
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + adjustedSpeed) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { yOffset = -40 }

            withAnimation(.linear(duration: stone.speed)) {
                yOffset = height + 40
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + stone.speed) {
                var t2 = Transaction()
                t2.disablesAnimations = true
                withTransaction(t2) { yOffset = -40 }
                startFall()
            }
        }
    }
}

// MARK: - Impact

fileprivate struct ImpactDrop: Identifiable {
    let id = UUID()
    let x: CGFloat
    let yOffset: CGFloat
    let interval: Double
    let angle: Double
}

fileprivate struct ImpactView: View {
    
    let impact: ImpactDrop
    let width: CGFloat
    let height: CGFloat
    let color: Color

    @State private var leftOpacity: Double = 0
    @State private var rightOpacity: Double = 0
    @State private var leftOffset: CGSize = .zero
    @State private var rightOffset: CGSize = .zero

    private var bottomY: CGFloat { height - 14 + impact.yOffset }

    var body: some View {
        ZStack {
            Capsule()
                .fill(color.opacity(leftOpacity))
                .frame(width: 1.8, height: 10)
                .rotationEffect(.degrees(-38 - impact.angle))
                .offset(leftOffset)

            Capsule()
                .fill(color.opacity(rightOpacity))
                .frame(width: 1.8, height: 10)
                .rotationEffect(.degrees(38 - impact.angle))
                .offset(rightOffset)

            // Fragmento central
            Capsule()
                .fill(color.opacity(leftOpacity * 0.6))
                .frame(width: 1.5, height: 7)
                .rotationEffect(.degrees(-impact.angle))
                .offset(CGSize(width: 0, height: leftOffset.height * 0.8))
        }
        .position(x: impact.x * width, y: bottomY)
        .onAppear {
            startImpact()
        }
    }

    private func startImpact() {
        leftOpacity = 0
        rightOpacity = 0
        leftOffset = .zero
        rightOffset = .zero

        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...impact.interval)) {
            withAnimation(.easeOut(duration: 0.20)) {
                leftOpacity  = 0.85
                rightOpacity = 0.85
                leftOffset   = CGSize(width: -8, height: -9)
                rightOffset  = CGSize(width:  8, height: -9)
            }
            withAnimation(.easeIn(duration: 0.25).delay(0.18)) {
                leftOpacity  = 0
                rightOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + impact.interval) {
                startImpact()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "4a5568").ignoresSafeArea()
        HailView(condition: [.day, .denseClouds, .hailing])
    }
}
