import SwiftUI

struct FogView: View {
    
    let condition: WeatherCondition

    private var isActive: Bool {
        condition.contains(.foggy)
    }

    private var fogColor: Color {
        condition.contains(.night) ? Color(hex: "8090a8") : Color(hex: "d8e8f0")
    }

    var body: some View {
        GeometryReader { geo in
            if isActive {
                ZStack {
                    // Bandas de niebla con movimiento horizontal
                    ForEach(0..<8, id: \.self) { i in
                        FogBandView(
                            index: i,
                            color: fogColor,
                            width: geo.size.width,
                            height: geo.size.height
                        )
                    }

                    // Volúmenes de niebla — manchas difusas que flotan
                    ForEach(0..<5, id: \.self) { i in
                        FogPuffView(
                            index: i,
                            color: fogColor,
                            width: geo.size.width,
                            height: geo.size.height
                        )
                    }
                }
            }
        }
        .drawingGroup()
        .animation(.easeInOut(duration: 1.2), value: isActive)
    }
}

// MARK: - Fog Band

private struct FogBandView: View {
    
    let index: Int
    let color: Color
    let width: CGFloat
    let height: CGFloat

    private var yFraction: CGFloat {
        let fractions: [CGFloat] = [0.28, 0.38, 0.48, 0.56, 0.64, 0.72, 0.80, 0.88]
        return fractions[index % fractions.count]
    }

    private var bandHeight: CGFloat {
        let heights: [CGFloat] = [140, 100, 160, 90, 130, 80, 110, 95]
        return heights[index % heights.count]
    }

    private var opacity: Double {
        let opacities: [Double] = [0.38, 0.22, 0.45, 0.18, 0.35, 0.28, 0.42, 0.20]
        return opacities[index % opacities.count]
    }

    private var duration: Double {
        let durations: [Double] = [14, 18, 11, 20, 15, 9, 16, 12]
        return durations[index % durations.count]
    }

    private var blurRadius: CGFloat {
        let blurs: [CGFloat] = [30, 20, 36, 16, 28, 22, 32, 18]
        return blurs[index % blurs.count]
    }

    private var movesRight: Bool { index % 2 == 0 }

    @State private var xOffset: CGFloat = 0
    @State private var currentOpacity: Double = 0
    @State private var scaleX: CGFloat = 1.0

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(0),
                        color.opacity(opacity * 1.2),
                        color.opacity(opacity),
                        color.opacity(opacity * 0.6),
                        color.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width * 1.6, height: bandHeight)
            .scaleEffect(x: scaleX, y: 1.0)
            .blur(radius: blurRadius)
            .offset(x: xOffset, y: height * yFraction)
            .opacity(currentOpacity)
            .onAppear {
                xOffset = movesRight
                    ? -width * CGFloat.random(in: 0.3...0.7)
                    :  width * CGFloat.random(in: 0.3...0.7)

                withAnimation(.easeIn(duration: Double.random(in: 1.5...3.0))) {
                    currentOpacity = 1.0
                }

                // Movimiento horizontal principal
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    xOffset = movesRight
                        ?  width * CGFloat.random(in: 0.10...0.25)
                        : -width * CGFloat.random(in: 0.10...0.25)
                }

                // Respiración — se expande y contrae
                withAnimation(
                    .easeInOut(duration: duration * 0.6)
                    .repeatForever(autoreverses: true)
                ) {
                    scaleX = CGFloat.random(in: 1.05...1.20)
                }

                // Pulso de opacidad — tonos claros y oscuros
                withAnimation(
                    .easeInOut(duration: duration * 0.4)
                    .repeatForever(autoreverses: true)
                ) {
                    currentOpacity = Double.random(in: 0.55...1.0)
                }
            }
    }
}

// MARK: - Fog Puff

private struct FogPuffView: View {
    
    let index: Int
    let color: Color
    let width: CGFloat
    let height: CGFloat

    private var yFraction: CGFloat {
        let fractions: [CGFloat] = [0.42, 0.58, 0.50, 0.68, 0.36]
        return fractions[index % fractions.count]
    }

    private var size: CGFloat {
        let sizes: [CGFloat] = [280, 220, 320, 200, 260]
        return sizes[index % sizes.count]
    }

    private var duration: Double {
        let durations: [Double] = [16, 22, 13, 19, 25]
        return durations[index % durations.count]
    }

    private var movesRight: Bool { index % 2 != 0 }

    @State private var xOffset: CGFloat = 0
    @State private var yDrift: CGFloat = 0
    @State private var puffOpacity: Double = 0
    @State private var puffScale: CGFloat = 0.8

    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.45),
                        color.opacity(0.20),
                        color.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size * 0.45)
            .blur(radius: 28)
            .scaleEffect(puffScale)
            .offset(x: xOffset, y: height * yFraction + yDrift)
            .opacity(puffOpacity)
            .onAppear {
                xOffset = movesRight
                    ? -size * 0.5
                    :  width + size * 0.5

                withAnimation(.easeIn(duration: Double.random(in: 2.0...4.0))) {
                    puffOpacity = 1.0
                    puffScale = 1.0
                }

                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    xOffset = movesRight
                        ?  width * 0.3
                        :  width * 0.7
                }

                // Deriva vertical suave
                withAnimation(
                    .easeInOut(duration: duration * 0.7)
                    .repeatForever(autoreverses: true)
                ) {
                    yDrift = CGFloat.random(in: -20...20)
                }

                // Pulso de escala
                withAnimation(
                    .easeInOut(duration: duration * 0.5)
                    .repeatForever(autoreverses: true)
                ) {
                    puffScale = CGFloat.random(in: 1.05...1.18)
                }
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "a8b5c8").ignoresSafeArea()
        FogView(condition: .foggyMorning)
    }
}
