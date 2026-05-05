import Foundation

final class MockWeatherRepository: WeatherRepositoryProtocol {
    
    // MARK: - Configurable for tests

    var weatherToReturn: WeatherData = .mock
    var forecastToReturn: [WeatherData] = WeatherData.mockForecast
    var forecastDaysToReturn: [ForecastDay] = ForecastDay.mockForecast
    var locationsToReturn: [Location] = Location.mockSearchResults
    var errorToThrow: Error?

    // MARK: - Protocol

    func fetchWeather(for location: Location) async throws -> WeatherData {
        if let error = errorToThrow { throw error }
        return weatherToReturn
    }

    func fetchForecast(for location: Location, days: Int) async throws -> [WeatherData] {
        if let error = errorToThrow { throw error }
        return Array(forecastToReturn.prefix(days))
    }

    func fetchForecastDays(for location: Location, days: Int) async throws -> [ForecastDay] {
        if let error = errorToThrow { throw error }
        return Array(forecastDaysToReturn.prefix(days))
    }

    func searchCities(query: String) async throws -> [Location] {
        if let error = errorToThrow { throw error }
        return locationsToReturn.filter {
            $0.name.lowercased().contains(query.lowercased())
        }
    }
}

// MARK: - ForecastDay Mock Extensions

extension ForecastDay {
    
    static let mockForecast: [ForecastDay] = [
        ForecastDay(
            date: Date(),
            condition: .sunnyDay,
            maxTempCelsius: 24,
            minTempCelsius: 16,
            precipitationMm: 0,
            humidity: 55,
            uvIndex: 5,
            description: "Soleado"
        ),
        ForecastDay(
            date: Date().addingTimeInterval(86400),
            condition: .cloudyDay,
            maxTempCelsius: 20,
            minTempCelsius: 14,
            precipitationMm: 0,
            humidity: 65,
            uvIndex: 3,
            description: "Nublado"
        ),
        ForecastDay(
            date: Date().addingTimeInterval(86400 * 2),
            condition: .lightRain,
            maxTempCelsius: 17,
            minTempCelsius: 12,
            precipitationMm: 4,
            humidity: 80,
            uvIndex: 1,
            description: "Lluvia leve"
        ),
        ForecastDay(
            date: Date().addingTimeInterval(86400 * 3),
            condition: .thunderstorm,
            maxTempCelsius: 14,
            minTempCelsius: 10,
            precipitationMm: 18,
            humidity: 90,
            uvIndex: 0,
            description: "Tormenta"
        ),
        ForecastDay(
            date: Date().addingTimeInterval(86400 * 4),
            condition: .cloudyDay,
            maxTempCelsius: 18,
            minTempCelsius: 13,
            precipitationMm: 2,
            humidity: 70,
            uvIndex: 2,
            description: "Nublado"
        ),
        ForecastDay(
            date: Date().addingTimeInterval(86400 * 5),
            condition: .sunnyDay,
            maxTempCelsius: 22,
            minTempCelsius: 15,
            precipitationMm: 0,
            humidity: 58,
            uvIndex: 4,
            description: "Soleado"
        ),
        ForecastDay(
            date: Date().addingTimeInterval(86400 * 6),
            condition: .goldenSunset,
            maxTempCelsius: 25,
            minTempCelsius: 17,
            precipitationMm: 0,
            humidity: 50,
            uvIndex: 6,
            description: "Despejado"
        )
    ]
}

// MARK: - Location Mock Extensions

extension Location {
    
    static let mock = Location(
        name: "Madrid",
        country: "Spain",
        latitude: 40.4168,
        longitude: -3.7038
    )

    static let mockSearchResults: [Location] = [
        Location(name: "Madrid", country: "España", latitude: 40.4168, longitude: -3.7038),
        Location(name: "Barcelona", country: "España", latitude: 41.3851, longitude: 2.1734),
        Location(name: "Oviedo", country: "España", latitude: 43.3603, longitude: -5.8448),
        Location(name: "Sevilla", country: "España", latitude: 37.3891, longitude: -5.9845),
        Location(name: "Valencia", country: "España", latitude: 39.4699, longitude: -0.3763)
    ]
}

// MARK: - WeatherData Mock Extensions

extension WeatherData {
    
    static let mock = WeatherData(
        location: .mock,
        condition: .sunnyDay,
        temperatureCelsius: 22.0,
        feelsLikeCelsius: 21.0,
        humidity: 55,
        windSpeedKmh: 12.0,
        precipitationMm: 0.0,
        visibilityKm: 10.0,
        uvIndex: 5,
        description: "Soleado",
        updatedAt: Date()
    )

    static let mockNight = WeatherData(
        location: .mock,
        condition: .clearNight,
        temperatureCelsius: 15.0,
        feelsLikeCelsius: 13.0,
        humidity: 70,
        windSpeedKmh: 8.0,
        precipitationMm: 0.0,
        visibilityKm: 10.0,
        uvIndex: 0,
        description: "Noche despejada",
        updatedAt: Date()
    )

    static let mockStorm = WeatherData(
        location: .mock,
        condition: .thunderstorm,
        temperatureCelsius: 12.0,
        feelsLikeCelsius: 9.0,
        humidity: 90,
        windSpeedKmh: 55.0,
        precipitationMm: 18.0,
        visibilityKm: 2.0,
        uvIndex: 0,
        description: "Tormenta eléctrica",
        updatedAt: Date()
    )

    static let mockSnow = WeatherData(
        location: .mock,
        condition: .heavySnow,
        temperatureCelsius: -3.0,
        feelsLikeCelsius: -7.0,
        humidity: 85,
        windSpeedKmh: 30.0,
        precipitationMm: 5.0,
        visibilityKm: 1.5,
        uvIndex: 1,
        description: "Nevada intensa",
        updatedAt: Date()
    )

    static let mockForecast: [WeatherData] = [
        .mock,
        mockNight,
        mockStorm,
        mockSnow
    ]
}
