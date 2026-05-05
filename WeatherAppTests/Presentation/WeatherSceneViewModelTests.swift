import XCTest
@testable import WeatherApp

@MainActor
final class WeatherSceneViewModelTests: XCTestCase {

    // MARK: - Properties

    var sut: MainViewModel!
    var mockRepository: MockWeatherRepository!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockRepository = MockWeatherRepository()
        sut = MainViewModel(
            fetchWeatherUseCase: FetchWeatherUseCase(repository: mockRepository)
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateIsCorrect() {
        XCTAssertNil(sut.weatherData)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.forecastDays.isEmpty)
        XCTAssertFalse(sut.showSearch)
        XCTAssertFalse(sut.showShowcase)
    }

    func testInitialConditionIsSunnyDay() {
        XCTAssertEqual(sut.currentCondition, .sunnyDay)
    }

    func testInitialTemperatureIsPlaceholder() {
        XCTAssertEqual(sut.temperature, "--°C")
    }

    func testInitialLocationIsMock() {
        XCTAssertEqual(sut.selectedLocation.name, "Madrid")
    }

    // MARK: - fetchWeather success

    func testFetchWeatherSetsWeatherData() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        XCTAssertNotNil(sut.weatherData)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testFetchWeatherSetsCorrectTemperature() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        XCTAssertEqual(sut.temperature, "22°C")
    }

    func testFetchWeatherSetsCorrectCondition() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        XCTAssertTrue(sut.currentCondition.contains(.sunny))
        XCTAssertTrue(sut.currentCondition.contains(.day))
    }

    func testFetchWeatherSetsForecastDays() async {
        mockRepository.weatherToReturn = .mock
        mockRepository.forecastDaysToReturn = ForecastDay.mockForecast
        await sut.fetchWeather()
        XCTAssertFalse(sut.forecastDays.isEmpty)
        XCTAssertEqual(sut.forecastDays.count, 7)
    }

    func testFetchWeatherSetsLocationName() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        XCTAssertEqual(sut.locationName, "Madrid, Spain")
    }

    // MARK: - fetchWeather failure

    func testFetchWeatherSetsErrorMessageOnFailure() async {
        mockRepository.errorToThrow = URLError(.notConnectedToInternet)
        await sut.fetchWeather()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.hasError)
        XCTAssertNil(sut.weatherData)
    }

    func testFetchWeatherIsNotLoadingAfterFailure() async {
        mockRepository.errorToThrow = URLError(.timedOut)
        await sut.fetchWeather()
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - selectLocation

    func testSelectLocationUpdatesSelectedLocation() async {
        let newLocation = Location(
            name: "Barcelona",
            country: "España",
            latitude: 41.3851,
            longitude: 2.1734
        )
        await sut.selectLocation(newLocation)
        XCTAssertEqual(sut.selectedLocation.name, "Barcelona")
    }

    func testSelectLocationHidesSearch() async {
        sut.showSearch = true
        let newLocation = Location.mockSearchResults[0]
        await sut.selectLocation(newLocation)
        XCTAssertFalse(sut.showSearch)
    }

    func testSelectLocationFetchesWeather() async {
        let newLocation = Location.mockSearchResults[0]
        await sut.selectLocation(newLocation)
        XCTAssertNotNil(sut.weatherData)
    }

    // MARK: - updateCondition

    func testUpdateConditionChangesWeatherDataCondition() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        sut.updateCondition(.thunderstorm, description: "Tormenta")
        XCTAssertEqual(sut.currentCondition, .thunderstorm)
    }

    func testUpdateConditionKeepsExistingTemperature() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        sut.updateCondition(.clearNight, description: "Noche despejada")
        XCTAssertEqual(sut.temperature, "22°C")
    }

    func testUpdateConditionChangesDescription() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        sut.updateCondition(.clearNight, description: "Noche despejada")
        XCTAssertEqual(sut.description, "Noche despejada")
    }

    // MARK: - Computed properties

    func testHumidityFormattedCorrectly() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        XCTAssertEqual(sut.humidity, "55%")
    }

    func testWindSpeedFormattedCorrectly() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        XCTAssertEqual(sut.windSpeed, "12 km/h")
    }

    func testVisibilityFormattedCorrectly() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        XCTAssertEqual(sut.visibility, "10 km")
    }

    func testUVIndexFormattedCorrectly() async {
        mockRepository.weatherToReturn = .mock
        await sut.fetchWeather()
        XCTAssertEqual(sut.uvIndex, "UV 5")
    }

    // MARK: - retry

    func testRetryFetchesWeatherAgain() async {
        mockRepository.errorToThrow = URLError(.notConnectedToInternet)
        await sut.fetchWeather()
        XCTAssertTrue(sut.hasError)

        mockRepository.errorToThrow = nil
        mockRepository.weatherToReturn = .mock
        await sut.retry()
        XCTAssertFalse(sut.hasError)
        XCTAssertNotNil(sut.weatherData)
    }
}
