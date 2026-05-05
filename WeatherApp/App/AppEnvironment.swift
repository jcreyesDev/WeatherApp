import Foundation

final class AppEnvironment {
    
    static let shared = AppEnvironment()

    let fetchWeatherUseCase: FetchWeatherUseCase

    private init() {
        let apiClient = WeatherAPIClient(apiKey: AppEnvironment.apiKey)
        let mapper = WeatherMapper()
        let repository = WeatherRepository(apiClient: apiClient, mapper: mapper)
        fetchWeatherUseCase = FetchWeatherUseCase(repository: repository)
    }

    // MARK: - Preview / Testing

    static func mock(_ data: WeatherData = .mock) -> FetchWeatherUseCase {
        let repository = MockWeatherRepository()
        repository.weatherToReturn = data
        return FetchWeatherUseCase(repository: repository)
    }

    static func mockFull() -> FetchWeatherUseCase {
        let repository = MockWeatherRepository()
        return FetchWeatherUseCase(repository: repository)
    }

    // MARK: - Private

    private static let apiKey: String = {
        guard let key = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String,
              !key.isEmpty else {
            #if DEBUG
            return "ec0f90e4a20843aeab1131807262904"
            #else
            fatalError("WEATHER_API_KEY no configurada en Info.plist")
            #endif
        }
        return key
    }()
}
