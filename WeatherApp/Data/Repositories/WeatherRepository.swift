import Foundation

final class WeatherRepository: WeatherRepositoryProtocol {
    
    private let apiClient: WeatherAPIClient
    private let mapper: WeatherMapper

    init(apiClient: WeatherAPIClient, mapper: WeatherMapper) {
        self.apiClient = apiClient
        self.mapper = mapper
    }

    // MARK: - Current Weather

    func fetchWeather(for location: Location) async throws -> WeatherData {
        let response = try await apiClient.fetchCurrentWeather(
            lat: location.latitude,
            lon: location.longitude
        )
        return mapper.map(response: response)
    }

    // MARK: - Forecast Weather

    func fetchForecast(for location: Location, days: Int) async throws -> [WeatherData] {
        let response = try await apiClient.fetchForecast(
            lat: location.latitude,
            lon: location.longitude,
            days: days
        )
        return mapper.map(forecastResponse: response)
    }

    // MARK: - Forecast Days

    func fetchForecastDays(for location: Location, days: Int) async throws -> [ForecastDay] {
        let response = try await apiClient.fetchForecastDays(
            lat: location.latitude,
            lon: location.longitude,
            days: days
        )
        return mapper.mapForecastDays(from: response)
    }

    // MARK: - Search Cities

    func searchCities(query: String) async throws -> [Location] {
        let results = try await apiClient.searchCities(query: query)
        return results.map { result in
            Location(
                name: result.name,
                country: result.country,
                latitude: result.lat,
                longitude: result.lon
            )
        }
    }
}
