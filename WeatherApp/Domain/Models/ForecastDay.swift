import Foundation

struct ForecastDay: Equatable {
    
    let date: Date
    let condition: WeatherCondition
    let maxTempCelsius: Double
    let minTempCelsius: Double
    let precipitationMm: Double
    let humidity: Int
    let uvIndex: Int
    let description: String

    // MARK: - Computed

    var formattedMaxTemp: String {
        "\(Int(maxTempCelsius.rounded()))°"
    }

    var formattedMinTemp: String {
        "\(Int(minTempCelsius.rounded()))°"
    }

    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date).capitalized
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}
