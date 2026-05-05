import SwiftUI

struct ForecastDayCard: View {
    
    let day: ForecastDay
    let isToday: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Día
            Text(isToday ? "Hoy" : day.dayName)
                .font(.system(size: 13, weight: isToday ? .semibold : .regular, design: .rounded))
                .foregroundStyle(.white.opacity(isToday ? 1.0 : 0.75))

            // Fecha
            Text(day.shortDate)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))

            // Icono
            Image(systemName: day.condition.sfSymbol)
                .font(.system(size: 22))
                .foregroundStyle(.white.opacity(0.9))
                .frame(height: 28)

            // Temp max
            Text(day.formattedMaxTemp)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            // Temp min
            Text(day.formattedMinTemp)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))

            // Precipitacion si hay
            if day.precipitationMm > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Color(hex: "7fa8c8"))
                    Text("\(Int(day.precipitationMm))mm")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "7fa8c8"))
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isToday ? Color.white.opacity(0.20) : Color.black.opacity(0.20))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isToday ? Color.white.opacity(0.35) : Color.white.opacity(0.10),
                            lineWidth: 0.5
                        )
                )
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "1b2d4a").ignoresSafeArea()
        HStack {
            ForecastDayCard(day: ForecastDay.mockForecast[0], isToday: true)
            ForecastDayCard(day: ForecastDay.mockForecast[1], isToday: false)
            ForecastDayCard(day: ForecastDay.mockForecast[2], isToday: false)
        }
        .padding()
    }
}
