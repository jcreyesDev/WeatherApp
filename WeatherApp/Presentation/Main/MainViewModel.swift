import Foundation
import Observation
import CoreLocation

@Observable
final class MainViewModel {
    
    // MARK: - State

    var weatherData: WeatherData?
    var forecastDays: [ForecastDay] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedLocation: Location = .mock
    var showSearch: Bool = false
    var showShowcase: Bool = false

    // MARK: - Dependencies

    private let fetchWeatherUseCase: FetchWeatherUseCase
    let locationManager = LocationManager()

    init(fetchWeatherUseCase: FetchWeatherUseCase) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
    }

    // MARK: - Computed

    var currentCondition: WeatherCondition {
        weatherData?.condition ?? .sunnyDay
    }

    var temperature: String {
        weatherData?.formattedTemperature ?? "--°C"
    }

    var feelsLike: String {
        weatherData?.formattedFeelsLike ?? "Sensación --°C"
    }

    var humidity: String {
        weatherData?.formattedHumidity ?? "--%"
    }

    var windSpeed: String {
        weatherData?.formattedWind ?? "-- km/h"
    }

    var visibility: String {
        guard let data = weatherData else { return "-- km" }
        return "\(Int(data.visibilityKm.rounded())) km"
    }

    var uvIndex: String {
        guard let data = weatherData else { return "UV --" }
        return "UV \(data.uvIndex)"
    }

    var locationName: String {
        weatherData?.location.displayName ?? selectedLocation.displayName
    }

    var description: String {
        weatherData?.description ?? ""
    }

    var hasError: Bool {
        errorMessage != nil
    }

    // MARK: - Actions

    func startLocationTracking() {
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // Ya tiene permisos — espera la ubicación real, no carga el mock
            locationManager.requestLocation()
        } else {
            // Primera vez — carga mock inmediato y pide permisos
            Task { await fetchWeather() }
            locationManager.requestLocation()
        }
    }

    func fetchWeather() async {
        isLoading = true
        errorMessage = nil

        do {
            async let weather = fetchWeatherUseCase.execute(for: selectedLocation)
            async let forecast = fetchWeatherUseCase.executeForecastDays(
                for: selectedLocation,
                days: 7
            )
            let (weatherResult, forecastResult) = try await (weather, forecast)
            weatherData = weatherResult
            forecastDays = forecastResult
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func selectLocation(_ location: Location) async {
        selectedLocation = location
        showSearch = false
        await fetchWeather()
    }

    func retry() async {
        locationManager.requestLocation()
        await fetchWeather()
    }

    func updateCondition(_ newCondition: WeatherCondition, description: String) {
        weatherData = WeatherData(
            location: selectedLocation,
            condition: newCondition,
            temperatureCelsius: weatherData?.temperatureCelsius ?? 18.0,
            feelsLikeCelsius: weatherData?.feelsLikeCelsius ?? 16.0,
            humidity: weatherData?.humidity ?? 65,
            windSpeedKmh: weatherData?.windSpeedKmh ?? 20.0,
            precipitationMm: weatherData?.precipitationMm ?? 0.0,
            visibilityKm: weatherData?.visibilityKm ?? 8.0,
            uvIndex: weatherData?.uvIndex ?? 3,
            description: description,
            updatedAt: Date()
        )
    }
}
