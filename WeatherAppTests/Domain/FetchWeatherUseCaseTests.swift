import XCTest
@testable import WeatherApp

@MainActor
final class FetchWeatherUseCaseTests: XCTestCase {

    // MARK: - Properties

    var sut: FetchWeatherUseCase!
    var mockRepository: MockWeatherRepository!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockRepository = MockWeatherRepository()
        sut = FetchWeatherUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - fetchWeather

    func testExecuteReturnsWeatherData() async throws {
        mockRepository.weatherToReturn = .mock
        let result = try await sut.execute(for: .mock)
        XCTAssertEqual(result.location.name, "Madrid")
        XCTAssertEqual(result.temperatureCelsius, 22.0)
    }

    func testExecuteThrowsWhenRepositoryFails() async {
        mockRepository.errorToThrow = URLError(.notConnectedToInternet)
        do {
            _ = try await sut.execute(for: .mock)
            XCTFail("Debería haber lanzado un error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testExecuteReturnsCorrectCondition() async throws {
        mockRepository.weatherToReturn = .mockStorm
        let result = try await sut.execute(for: .mock)
        XCTAssertTrue(result.condition.contains(.thunder))
        XCTAssertTrue(result.condition.contains(.rainy))
    }

    // MARK: - fetchForecastDays

    func testExecuteForecastDaysReturnsCorrectCount() async throws {
        mockRepository.forecastDaysToReturn = ForecastDay.mockForecast
        let result = try await sut.executeForecastDays(for: .mock, days: 7)
        XCTAssertEqual(result.count, 7)
    }

    func testExecuteForecastDaysRespectsLimit() async throws {
        mockRepository.forecastDaysToReturn = ForecastDay.mockForecast
        let result = try await sut.executeForecastDays(for: .mock, days: 3)
        XCTAssertEqual(result.count, 3)
    }

    func testExecuteForecastDaysThrowsWhenRepositoryFails() async {
        mockRepository.errorToThrow = URLError(.timedOut)
        do {
            _ = try await sut.executeForecastDays(for: .mock, days: 7)
            XCTFail("Debería haber lanzado un error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - searchCities

    func testExecuteSearchReturnsResults() async throws {
        let result = try await sut.executeSearch(query: "Madrid")
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains { $0.name == "Madrid" })
    }

    func testExecuteSearchReturnsEmptyForUnknownCity() async throws {
        let result = try await sut.executeSearch(query: "XYZCiudadInexistente")
        XCTAssertTrue(result.isEmpty)
    }

    func testExecuteSearchThrowsWhenRepositoryFails() async {
        mockRepository.errorToThrow = URLError(.notConnectedToInternet)
        do {
            _ = try await sut.executeSearch(query: "Madrid")
            XCTFail("Debería haber lanzado un error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
