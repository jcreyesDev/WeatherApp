import SwiftUI

struct ForecastScrollView: View {
    
    let days: [ForecastDay]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    ForecastDayCard(
                        day: day,
                        isToday: index == 0
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "1b2d4a").ignoresSafeArea()
        ForecastScrollView(days: ForecastDay.mockForecast)
    }
}
