import SwiftUI

struct CloudsView: View {
    
    let condition: WeatherCondition

    fileprivate struct CloudItem: Identifiable {
        let id = UUID()
        let yFraction: CGFloat
        let scale: CGFloat
        let speed: Double
        let opacity: Double
        let startXFraction: CGFloat
        let layer: CloudLayer
        let blur: CGFloat
        let movesRight: Bool
    }

    fileprivate enum CloudLayer {
        case back
        case front
    }

    // Nubes normales — claras, livianas
    private let normalClouds: [CloudItem] = [
        CloudItem(yFraction: 0.10, scale: 2.0, speed: 55, opacity: 0.40, startXFraction:  0.2, layer: .back,  blur: 10, movesRight: true),
        CloudItem(yFraction: 0.22, scale: 1.6, speed: 48, opacity: 0.35, startXFraction:  0.7, layer: .back,  blur: 12, movesRight: false),
        CloudItem(yFraction: 0.15, scale: 1.8, speed: 62, opacity: 0.30, startXFraction: -0.3, layer: .back,  blur: 14, movesRight: true),
        CloudItem(yFraction: 0.35, scale: 1.4, speed: 70, opacity: 0.28, startXFraction:  1.1, layer: .back,  blur: 10, movesRight: false),
        CloudItem(yFraction: 0.14, scale: 1.3, speed: 32, opacity: 0.92, startXFraction: -0.3, layer: .front, blur: 3,  movesRight: true),
        CloudItem(yFraction: 0.38, scale: 1.0, speed: 38, opacity: 0.88, startXFraction:  1.2, layer: .front, blur: 3,  movesRight: false),
        CloudItem(yFraction: 0.10, scale: 1.5, speed: 28, opacity: 0.95, startXFraction: -0.6, layer: .front, blur: 4,  movesRight: true),
        CloudItem(yFraction: 0.44, scale: 0.9, speed: 42, opacity: 0.82, startXFraction:  0.9, layer: .front, blur: 3,  movesRight: false),
        CloudItem(yFraction: 0.27, scale: 1.2, speed: 35, opacity: 0.90, startXFraction:  0.4, layer: .front, blur: 4,  movesRight: true),
    ]

    // Nubes densas — oscuras, más bajas, más lentas
    private let denseCloudsItems: [CloudItem] = [
        CloudItem(yFraction: 0.08, scale: 2.2, speed: 45, opacity: 0.55, startXFraction:  0.1, layer: .back,  blur: 14, movesRight: true),
        CloudItem(yFraction: 0.18, scale: 1.8, speed: 38, opacity: 0.60, startXFraction:  0.8, layer: .back,  blur: 16, movesRight: false),
        CloudItem(yFraction: 0.12, scale: 2.0, speed: 52, opacity: 0.50, startXFraction: -0.4, layer: .back,  blur: 18, movesRight: true),
        CloudItem(yFraction: 0.30, scale: 1.6, speed: 60, opacity: 0.45, startXFraction:  1.2, layer: .back,  blur: 12, movesRight: false),
        CloudItem(yFraction: 0.22, scale: 1.5, speed: 25, opacity: 0.98, startXFraction: -0.3, layer: .front, blur: 2,  movesRight: true),
        CloudItem(yFraction: 0.35, scale: 1.2, speed: 30, opacity: 0.95, startXFraction:  1.1, layer: .front, blur: 2,  movesRight: false),
        CloudItem(yFraction: 0.18, scale: 1.7, speed: 22, opacity: 1.00, startXFraction: -0.5, layer: .front, blur: 3,  movesRight: true),
        CloudItem(yFraction: 0.42, scale: 1.0, speed: 35, opacity: 0.90, startXFraction:  0.8, layer: .front, blur: 2,  movesRight: false),
        CloudItem(yFraction: 0.28, scale: 1.4, speed: 28, opacity: 0.95, startXFraction:  0.3, layer: .front, blur: 3,  movesRight: true),
    ]

    private var hasClouds: Bool {
        condition.contains(.cloudy)
    }

    private var hasDenseClouds: Bool {
        condition.contains(.denseClouds)
    }

    // Color según tipo de nube y momento del día
    private var normalCloudColor: Color {
        condition.contains(.night) || condition.contains(.dawn) || condition.contains(.dusk)
            ? Color.white.opacity(0.55)
            : Color.white.opacity(0.92)
    }

    private var normalCloudBackColor: Color {
        condition.contains(.night) || condition.contains(.dawn) || condition.contains(.dusk)
            ? Color.white.opacity(0.20)
            : Color.white.opacity(0.55)
    }

    private var denseCloudColor: Color {
        condition.contains(.night)
            ? Color.white.opacity(0.30)
            : Color.white.opacity(0.50)
    }

    private var denseCloudBackColor: Color {
        condition.contains(.night)
            ? Color.white.opacity(0.15)
            : Color.white.opacity(0.28)
    }

    var body: some View {
        GeometryReader { geo in
            // Nubes normales
            if hasClouds {
                ForEach(normalClouds.filter { $0.layer == .back }) { cloud in
                    AnimatedCloudView(
                        cloud: cloud,
                        color: normalCloudBackColor,
                        width: geo.size.width,
                        height: geo.size.height
                    )
                }
                ForEach(normalClouds.filter { $0.layer == .front }) { cloud in
                    AnimatedCloudView(
                        cloud: cloud,
                        color: normalCloudColor,
                        width: geo.size.width,
                        height: geo.size.height
                    )
                }
            }

            // Nubes densas
            if hasDenseClouds {
                ForEach(denseCloudsItems.filter { $0.layer == .back }) { cloud in
                    AnimatedCloudView(
                        cloud: cloud,
                        color: denseCloudBackColor,
                        width: geo.size.width,
                        height: geo.size.height
                    )
                }
                ForEach(denseCloudsItems.filter { $0.layer == .front }) { cloud in
                    AnimatedCloudView(
                        cloud: cloud,
                        color: denseCloudColor,
                        width: geo.size.width,
                        height: geo.size.height
                    )
                }
            }
        }
        .drawingGroup()
        .animation(.easeInOut(duration: 1.5), value: condition)
    }
}

// MARK: - Animated Cloud View

fileprivate struct AnimatedCloudView: View {
    
    let cloud: CloudsView.CloudItem
    let color: Color
    let width: CGFloat
    let height: CGFloat

    @State private var xOffset: CGFloat = 0
    @State private var started = false

    private var startX: CGFloat {
        cloud.movesRight ? -300 * cloud.scale : width + 300 * cloud.scale
    }

    private var endX: CGFloat {
        cloud.movesRight ? width + 300 * cloud.scale : -300 * cloud.scale
    }

    var body: some View {
        CloudShape(seed: abs(cloud.id.hashValue))
            .fill(color.opacity(cloud.opacity))
            .frame(width: 200 * cloud.scale, height: 90 * cloud.scale)
            .blur(radius: cloud.blur)
            .offset(x: xOffset, y: cloud.yFraction * height)
            .onAppear {
                guard !started else { return }
                started = true
                xOffset = width * cloud.startXFraction

                let totalDistance = abs(endX - startX)
                let remaining = abs(endX - width * cloud.startXFraction)
                let adjustedSpeed = cloud.speed * Double(remaining / totalDistance)

                withAnimation(.linear(duration: adjustedSpeed)) {
                    xOffset = endX
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + adjustedSpeed) {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) { xOffset = startX }

                    withAnimation(.linear(duration: cloud.speed).repeatForever(autoreverses: false)) {
                        xOffset = endX
                    }
                }
            }
    }
}

// MARK: - Cloud Shape

private struct CloudShape: Shape {
    
    let seed: Int

    func path(in rect: CGRect) -> Path {
        var rng = SeededRandom(seed: seed)
        var path = Path()

        let w = rect.width
        let h = rect.height
        let cx = w * 0.5
        let cy = h * 0.5

        path.addEllipse(in: CGRect(
            x: cx - w * 0.38,
            y: cy - h * 0.28,
            width: w * 0.76,
            height: h * 0.56
        ))

        let bumpCount = 3 + (seed % 3)
        for i in 0..<bumpCount {
            let fraction = CGFloat(i) / CGFloat(max(bumpCount - 1, 1))
            let jitter   = rng.nextCGFloat(in: -8...8)
            let bumpCX   = w * (0.18 + fraction * 0.64) + jitter
            let bumpW    = w * rng.nextCGFloat(in: 0.28...0.44)
            let bumpH    = h * rng.nextCGFloat(in: 0.40...0.65)
            let bumpY    = cy - bumpH * rng.nextCGFloat(in: 0.55...0.80)

            path.addEllipse(in: CGRect(
                x: bumpCX - bumpW / 2,
                y: bumpY,
                width: bumpW,
                height: bumpH
            ))
        }

        path.addEllipse(in: CGRect(
            x: w * 0.02,
            y: cy - h * 0.18,
            width: w * 0.28,
            height: h * 0.36
        ))

        path.addEllipse(in: CGRect(
            x: w * 0.70,
            y: cy - h * 0.18,
            width: w * 0.28,
            height: h * 0.36
        ))

        return path
    }
}

// MARK: - Seeded Random

private struct SeededRandom {
    
    var seed: Int

    mutating func nextCGFloat(in range: ClosedRange<CGFloat>) -> CGFloat {
        seed = seed &* 1664525 &+ 1013904223
        let t = CGFloat(abs(seed) % 10000) / 10000.0
        return range.lowerBound + t * (range.upperBound - range.lowerBound)
    }

    mutating func nextDouble(in range: ClosedRange<Double>) -> Double {
        seed = seed &* 1664525 &+ 1013904223
        let t = Double(abs(seed) % 10000) / 10000.0
        return range.lowerBound + t * (range.upperBound - range.lowerBound)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "4a6080").ignoresSafeArea()
        CloudsView(condition: .cloudyDay)
    }
}
