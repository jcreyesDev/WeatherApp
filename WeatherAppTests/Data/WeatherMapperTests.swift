import XCTest
@testable import WeatherApp

@MainActor
final class WeatherMapperTests: XCTestCase {

    // MARK: - Properties

    var sut: WeatherMapper!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        sut = WeatherMapper()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - mapCondition day

    func testClearSunnyDayCode1000() {
        let response = makeCurrentResponse(code: 1000, isDay: 1)
        let result = sut.map(response: response)
        XCTAssertTrue(result.condition.contains(.day))
        XCTAssertTrue(result.condition.contains(.sunny))
        XCTAssertFalse(result.condition.contains(.night))
    }

    func testPartlyCloudyDayCode1003() {
        let response = makeCurrentResponse(code: 1003, isDay: 1)
        let result = sut.map(response: response)
        XCTAssertTrue(result.condition.contains(.day))
        XCTAssertTrue(result.condition.contains(.cloudy))
        XCTAssertTrue(result.condition.contains(.sunny))
    }

    func testOvercastDayCode1009() {
        let response = makeCurrentResponse(code: 1009, isDay: 1)
        let result = sut.map(response: response)
        XCTAssertTrue(result.condition.contains(.day))
        XCTAssertTrue(result.condition.contains(.denseClouds))
        XCTAssertFalse(result.condition.contains(.sunny))
    }

    func testThunderstormDayCode1087() {
        let response = makeCurrentResponse(code: 1087, isDay: 1)
        let result = sut.map(response: response)
        XCTAssertTrue(result.condition.contains(.day))
        XCTAssertTrue(result.condition.contains(.thunder))
        XCTAssertTrue(result.condition.contains(.rainy))
        XCTAssertTrue(result.condition.contains(.windy))
        XCTAssertTrue(result.condition.contains(.denseClouds))
    }

    func testSnowCode1066() {
        let response = makeCurrentResponse(code: 1066, isDay: 1)
        let result = sut.map(response: response)
        XCTAssertTrue(result.condition.contains(.snowy))
        XCTAssertTrue(result.condition.contains(.cloudy))
        XCTAssertFalse(result.condition.contains(.rainy))
    }

    // MARK: - mapCondition night

    func testClearNightCode1000() {
        let response = makeCurrentResponse(code: 1000, isDay: 0)
        let result = sut.map(response: response)
        XCTAssertTrue(result.condition.contains(.night))
        XCTAssertTrue(result.condition.contains(.moon))
        XCTAssertTrue(result.condition.contains(.stars))
        XCTAssertFalse(result.condition.contains(.day))
        XCTAssertFalse(result.condition.contains(.sunny))
    }

    func testThunderstormNightCode1087() {
        let response = makeCurrentResponse(code: 1087, isDay: 0)
        let result = sut.map(response: response)
        XCTAssertTrue(result.condition.contains(.night))
        XCTAssertTrue(result.condition.contains(.thunder))
        XCTAssertTrue(result.condition.contains(.rainy))
        XCTAssertFalse(result.condition.contains(.moon))
        XCTAssertFalse(result.condition.contains(.stars))
    }

    func testCloudyNightRemovesStars() {
        let response = makeCurrentResponse(code: 1003, isDay: 0)
        let result = sut.map(response: response)
        XCTAssertTrue(result.condition.contains(.night))
        XCTAssertTrue(result.condition.contains(.cloudy))
        XCTAssertFalse(result.condition.contains(.stars))
    }

    // MARK: - map location

    func testMapLocationCorrectly() {
        let response = makeCurrentResponse(code: 1000, isDay: 1)
        let result = sut.map(response: response)
        XCTAssertEqual(result.location.name, "Madrid")
        XCTAssertEqual(result.location.country, "España")
        XCTAssertEqual(result.location.latitude, 40.4168)
        XCTAssertEqual(result.location.longitude, -3.7038)
    }

    // MARK: - map weather data

    func testMapTemperatureCorrectly() {
        let response = makeCurrentResponse(code: 1000, isDay: 1, tempC: 25.5)
        let result = sut.map(response: response)
        XCTAssertEqual(result.temperatureCelsius, 25.5)
    }

    func testMapHumidityCorrectly() {
        let response = makeCurrentResponse(code: 1000, isDay: 1, humidity: 75)
        let result = sut.map(response: response)
        XCTAssertEqual(result.humidity, 75)
    }

    // MARK: - mapForecastDays

    func testMapForecastDaysReturnsCorrectCount() {
        let response = makeForecastResponse(days: 7)
        let result = sut.mapForecastDays(from: response)
        XCTAssertEqual(result.count, 7)
    }

    func testMapForecastDaysParsesDateCorrectly() {
        let response = makeForecastResponse(days: 1)
        let result = sut.mapForecastDays(from: response)
        XCTAssertNotNil(result.first?.date)
    }

    func testMapForecastDaysSkipsInvalidDates() {
        let response = makeForecastResponseWithInvalidDate()
        let result = sut.mapForecastDays(from: response)
        XCTAssertEqual(result.count, 0)
    }

    // MARK: - Helpers

    private func makeCurrentResponse(
        code: Int,
        isDay: Int,
        tempC: Double = 20.0,
        humidity: Int = 60
    ) -> WeatherAPIResponse {
        WeatherAPIResponse(
            location: WeatherAPILocation(
                name: "Madrid",
                country: "España",
                lat: 40.4168,
                lon: -3.7038
            ),
            current: WeatherAPICurrent(
                tempC: tempC,
                feelslikeC: tempC - 1,
                humidity: humidity,
                windKph: 15.0,
                precipMm: 0.0,
                visKm: 10.0,
                uv: 3.0,
                isDay: isDay,
                condition: WeatherAPICondition(text: "Test", code: code)
            )
        )
    }

    private func makeForecastResponse(days: Int) -> WeatherAPIForecastResponse {
        let forecastDays = (0..<days).map { i -> WeatherAPIForecastDay in
            let date = Calendar.current.date(
                byAdding: .day,
                value: i,
                to: Date()
            )!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return WeatherAPIForecastDay(
                date: formatter.string(from: date),
                day: WeatherAPIDay(
                    avgtempC: 20.0,
                    maxwindKph: 10.0,
                    totalprecipMm: 0.0,
                    avgvisKm: 10.0,
                    avghumidity: 60,
                    uvIndex: 3.0,
                    condition: WeatherAPICondition(text: "Sunny", code: 1000)
                )
            )
        }

        return WeatherAPIForecastResponse(
            location: WeatherAPILocation(
                name: "Madrid",
                country: "España",
                lat: 40.4168,
                lon: -3.7038
            ),
            forecast: WeatherAPIForecast(forecastday: forecastDays)
        )
    }

    private func makeForecastResponseWithInvalidDate() -> WeatherAPIForecastResponse {
        WeatherAPIForecastResponse(
            location: WeatherAPILocation(
                name: "Madrid",
                country: "España",
                lat: 40.4168,
                lon: -3.7038
            ),
            forecast: WeatherAPIForecast(
                forecastday: [
                    WeatherAPIForecastDay(
                        date: "fecha-invalida",
                        day: WeatherAPIDay(
                            avgtempC: 20.0,
                            maxwindKph: 10.0,
                            totalprecipMm: 0.0,
                            avgvisKm: 10.0,
                            avghumidity: 60,
                            uvIndex: 3.0,
                            condition: WeatherAPICondition(text: "Sunny", code: 1000)
                        )
                    )
                ]
            )
        )
    }
}
