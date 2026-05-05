import Foundation

final class FetchWeatherUseCase {
    
    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Current Weather

    func execute(for location: Location) async throws -> WeatherData {
        try await repository.fetchWeather(for: location)
    }

    // MARK: - Forecast Weather

    func executeForecast(for location: Location, days: Int = 7) async throws -> [WeatherData] {
        try await repository.fetchForecast(for: location, days: days)
    }

    // MARK: - Forecast Days

    func executeForecastDays(for location: Location, days: Int = 7) async throws -> [ForecastDay] {
        try await repository.fetchForecastDays(for: location, days: days)
    }

    // MARK: - Search Cities

    func executeSearch(query: String) async throws -> [Location] {
        try await repository.searchCities(query: query)
    }
}
