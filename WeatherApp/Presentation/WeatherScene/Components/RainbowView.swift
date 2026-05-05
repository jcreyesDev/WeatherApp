import SwiftUI

struct RainbowView: View {
    
    let condition: WeatherCondition

    @State private var appeared = false
    @State private var shimmer = false

    private var isActive: Bool {
        condition.contains(.rainbow)
    }

    private let bands: [(color: String, opacity: Double)] = [
        ("FF0000", 0.60),
        ("FF5500", 0.55),
        ("FF9900", 0.55),
        ("FFEE00", 0.52),
        ("44BB00", 0.50),
        ("0066FF", 0.48),
        ("6600CC", 0.45),
        ("9900FF", 0.42)
    ]

    var body: some View {
        GeometryReader { geo in
            if isActive {
                ZStack {
                    ForEach(Array(bands.enumerated()), id: \.offset) { i, band in
                        RainbowArc(
                            index: i,
                            color: band.color,
                            opacity: band.opacity * (shimmer ? 1.1 : 1.0),
                            width: geo.size.width,
                            height: geo.size.height
                        )
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            .easeInOut(duration: 1.4)
                            .delay(Double(i) * 0.06),
                            value: appeared
                        )
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        appeared = true
                    }
                    withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                        shimmer = true
                    }
                }
                .onChange(of: isActive) {
                    withAnimation(.easeInOut(duration: isActive ? 1.5 : 1.0)) {
                        appeared = isActive
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 1.0), value: isActive)
    }
}

// MARK: - Rainbow Arc

private struct RainbowArc: View {
    
    let index: Int
    let color: String
    let opacity: Double
    let width: CGFloat
    let height: CGFloat

    private let bandSpacing: CGFloat = 14
    private let centerXFraction: CGFloat = 0.15
    private let centerYFraction: CGFloat = 1.1
    private let radiusFraction: CGFloat = 1.1

    private var arcRadius: CGFloat {
        width * radiusFraction + CGFloat(index) * bandSpacing
    }

    var body: some View {
        Circle()
            .stroke(
                Color(hex: color).opacity(opacity),
                style: StrokeStyle(lineWidth: bandSpacing - 1, lineCap: .round)
            )
            .frame(width: arcRadius * 2, height: arcRadius * 2)
            .position(
                x: width * centerXFraction,
                y: height * centerYFraction
            )
            .blur(radius: 12)
            .frame(width: width, height: height)
            .clipped()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "5a8ab0"), Color(hex: "8ab4cc")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        RainbowView(condition: .rainbowAfterRain)
    }
}
