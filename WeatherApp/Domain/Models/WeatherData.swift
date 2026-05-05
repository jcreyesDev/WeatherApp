import Foundation

struct WeatherData: Equatable {
    
    let location: Location
    let condition: WeatherCondition
    let temperatureCelsius: Double
    let feelsLikeCelsius: Double
    let humidity: Int           // porcentaje 0-100
    let windSpeedKmh: Double
    let precipitationMm: Double
    let visibilityKm: Double
    let uvIndex: Int
    let description: String
    let updatedAt: Date

    // MARK: - Computed
    var temperatureFahrenheit: Double {
        (temperatureCelsius * 9 / 5) + 32
    }

    var isDay: Bool {
        condition.contains(.day) || condition.contains(.dawn) || condition.contains(.dusk)
    }

    var formattedTemperature: String {
        "\(Int(temperatureCelsius.rounded()))°C"
    }

    var formattedFeelsLike: String {
        "Sensación \(Int(feelsLikeCelsius.rounded()))°C"
    }

    var formattedHumidity: String {
        "\(humidity)%"
    }

    var formattedWind: String {
        "\(Int(windSpeedKmh.rounded())) km/h"
    }
}
