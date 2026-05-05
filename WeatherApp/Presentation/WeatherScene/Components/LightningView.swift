import SwiftUI

struct LightningView: View {
    
    let condition: WeatherCondition

    @State private var activeBolt: Int = 0
    @State private var flashOpacity: Double = 0
    @State private var boltOpacity: Double = 0
    @State private var strikeTask: Task<Void, Never>? = nil

    private var isActive: Bool {
        condition.contains(.thunder)
    }

    var body: some View {
        ZStack {
            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            GeometryReader { geo in
                if boltOpacity > 0 {
                    LightningBoltShape(seed: activeBolt)
                        .stroke(Color.white.opacity(boltOpacity), lineWidth: 1.8)
                        .frame(width: 60, height: 260)
                        .shadow(color: Color(hex: "AADFFF").opacity(0.9), radius: 6)
                        .shadow(color: Color(hex: "AADFFF").opacity(0.5), radius: 14)
                        .position(
                            x: geo.size.width * boltXPositions[activeBolt % boltXPositions.count],
                            y: geo.size.height * 0.38
                        )

                    LightningBoltShape(seed: activeBolt + 99)
                        .stroke(Color.white.opacity(boltOpacity * 0.55), lineWidth: 1.0)
                        .frame(width: 40, height: 200)
                        .shadow(color: Color(hex: "AADFFF").opacity(0.4), radius: 4)
                        .position(
                            x: geo.size.width * boltXPositions[(activeBolt + 1) % boltXPositions.count],
                            y: geo.size.height * 0.34
                        )

                    LightningBoltShape(seed: activeBolt + 55)
                        .stroke(Color.white.opacity(boltOpacity * 0.35), lineWidth: 0.8)
                        .frame(width: 32, height: 160)
                        .shadow(color: Color(hex: "AADFFF").opacity(0.3), radius: 3)
                        .position(
                            x: geo.size.width * boltXPositions[(activeBolt + 2) % boltXPositions.count],
                            y: geo.size.height * 0.40
                        )

                    LightningBoltShape(seed: activeBolt + 33)
                        .stroke(Color.white.opacity(boltOpacity * 0.20), lineWidth: 0.6)
                        .frame(width: 24, height: 130)
                        .shadow(color: Color(hex: "AADFFF").opacity(0.2), radius: 2)
                        .position(
                            x: geo.size.width * boltXPositions[(activeBolt + 3) % boltXPositions.count],
                            y: geo.size.height * 0.36
                        )
                }
            }
        }
        .drawingGroup()
        .onChange(of: condition) {
            if isActive {
                startStriking()
            } else {
                stopStriking()
            }
        }
        .onAppear {
            if isActive { startStriking() }
        }
        .onDisappear {
            stopStriking()
        }
    }

    // MARK: - Private

    private let boltXPositions: [Double] = [0.12, 0.28, 0.42, 0.58, 0.72, 0.88, 0.20, 0.65]

    private func startStriking() {
        strikeTask?.cancel()
        strikeTask = Task {
            while !Task.isCancelled && isActive {
                let delay = Double.random(in: 2.5...7.0)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled && isActive else { break }
                await MainActor.run { strikeSequence() }
            }
        }
    }

    private func stopStriking() {
        strikeTask?.cancel()
        strikeTask = nil
        withAnimation(.easeOut(duration: 0.2)) {
            flashOpacity = 0
            boltOpacity = 0
        }
    }

    private func strikeSequence() {
        activeBolt = Int.random(in: 0...99)

        withAnimation(.easeIn(duration: 0.04)) {
            flashOpacity = 0.18
            boltOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            withAnimation(.easeOut(duration: 0.08)) {
                flashOpacity = 0
                boltOpacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            guard isActive else { return }
            withAnimation(.easeIn(duration: 0.03)) {
                flashOpacity = 0.10
                boltOpacity = 0.7
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeOut(duration: 0.12)) {
                    flashOpacity = 0
                    boltOpacity = 0
                }
            }
        }
    }
}

// MARK: - Lightning Bolt Shape

private struct LightningBoltShape: Shape {
    
    let seed: Int

    func path(in rect: CGRect) -> Path {
        var rng = SeededRandomLightning(seed: abs(seed))
        var path = Path()
        let w = rect.width
        let h = rect.height
        var points: [CGPoint] = []

        points.append(CGPoint(x: w * 0.5, y: 0))

        let segments = 4 + (abs(seed) % 3)
        for i in 1..<segments {
            let progress = CGFloat(i) / CGFloat(segments)
            let xOffset = rng.next(in: -w * 0.45...w * 0.45)
            points.append(CGPoint(x: w * 0.5 + xOffset, y: h * progress))
        }

        points.append(CGPoint(x: w * rng.next(in: 0.2...0.8), y: h))

        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        return path
    }
}

// MARK: - Seeded Random

private struct SeededRandomLightning {
    
    var seed: Int

    mutating func next(in range: ClosedRange<CGFloat>) -> CGFloat {
        seed = seed &* 1664525 &+ 1013904223
        let t = CGFloat(abs(seed) % 10000) / 10000.0
        return range.lowerBound + t * (range.upperBound - range.lowerBound)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "0a0a1a").ignoresSafeArea()
        LightningView(condition: .thunderstorm)
    }
}
