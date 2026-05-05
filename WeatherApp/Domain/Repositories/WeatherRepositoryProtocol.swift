import Foundation

protocol WeatherRepositoryProtocol {
    
    func fetchWeather(for location: Location) async throws -> WeatherData
    func fetchForecast(for location: Location, days: Int) async throws -> [WeatherData]
    func fetchForecastDays(for location: Location, days: Int) async throws -> [ForecastDay]
    func searchCities(query: String) async throws -> [Location]
}
