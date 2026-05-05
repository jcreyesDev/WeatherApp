import SwiftUI

struct WindView: View {
    
    let condition: WeatherCondition

    fileprivate struct WindLine: Identifiable {
        let id = UUID()
        let yFraction: CGFloat
        let width: CGFloat
        let speed: Double
        let delay: Double
        let opacity: Double
        let curvature: CGFloat
    }

    private let lines: [WindLine] = (0..<18).map { _ in
        WindLine(
            yFraction: CGFloat.random(in: 0.1...0.85),
            width: CGFloat.random(in: 60...160),
            speed: Double.random(in: 0.6...1.2),
            delay: Double.random(in: 0...2.5),
            opacity: Double.random(in: 0.2...0.5),
            curvature: CGFloat.random(in: -8...8)
        )
    }

    private var isActive: Bool {
        condition.contains(.windy)
    }

    var body: some View {
        GeometryReader { geo in
            if isActive {
                ForEach(lines) { line in
                    WindLineView(
                        line: line,
                        screenWidth: geo.size.width,
                        screenHeight: geo.size.height
                    )
                }
            }
        }
        .drawingGroup()
        .animation(.easeInOut(duration: 0.5), value: isActive)
    }
}

fileprivate struct WindLineView: View {
    
    let line: WindView.WindLine
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var xOffset: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        WindCurveShape(curvature: line.curvature)
            .stroke(
                LinearGradient(
                    colors: [.clear, .white.opacity(line.opacity), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
            )
            .frame(width: line.width, height: 12)
            .position(x: xOffset, y: line.yFraction * screenHeight)
            .onAppear {
                xOffset = -line.width
                opacity = 0
                withAnimation(
                    .linear(duration: line.speed)
                    .delay(line.delay)
                    .repeatForever(autoreverses: false)
                ) {
                    xOffset = screenWidth + line.width
                }
                withAnimation(
                    .easeInOut(duration: line.speed * 0.3)
                    .delay(line.delay)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = 1
                }
            }
    }
}

private struct WindCurveShape: Shape {
    
    let curvature: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.midY + curvature)
        )
        return path
    }
}

#Preview {
    ZStack {
        Color(hex: "2c3e50").ignoresSafeArea()
        WindView(condition: .thunderstorm)
    }
}
