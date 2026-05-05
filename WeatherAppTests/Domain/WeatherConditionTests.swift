import XCTest
@testable import WeatherApp

@MainActor
final class WeatherConditionTests: XCTestCase {

    // MARK: - OptionSet combinability

    func testConditionsAreCombinableWithUnion() {
        let condition: WeatherCondition = [.day, .sunny, .cloudy]
        XCTAssertTrue(condition.contains(.day))
        XCTAssertTrue(condition.contains(.sunny))
        XCTAssertTrue(condition.contains(.cloudy))
        XCTAssertFalse(condition.contains(.night))
        XCTAssertFalse(condition.contains(.rainy))
    }

    func testConditionInsertAndRemove() {
        var condition: WeatherCondition = [.day, .sunny]
        condition.insert(.cloudy)
        XCTAssertTrue(condition.contains(.cloudy))
        condition.remove(.cloudy)
        XCTAssertFalse(condition.contains(.cloudy))
    }

    func testEmptyCondition() {
        let condition = WeatherCondition()
        XCTAssertFalse(condition.contains(.day))
        XCTAssertFalse(condition.contains(.night))
        XCTAssertTrue(condition.isEmpty)
    }

    func testConditionsAreExclusiveByDesign() {
        // Day y night pueden coexistir en el OptionSet pero
        // la lógica de negocio los trata como excluyentes
        let condition: WeatherCondition = [.day, .night]
        XCTAssertTrue(condition.contains(.day))
        XCTAssertTrue(condition.contains(.night))
    }

    // MARK: - Presets

    func testSunnyDayPreset() {
        let condition = WeatherCondition.sunnyDay
        XCTAssertTrue(condition.contains(.day))
        XCTAssertTrue(condition.contains(.sunny))
        XCTAssertFalse(condition.contains(.night))
        XCTAssertFalse(condition.contains(.rainy))
    }

    func testClearNightPreset() {
        let condition = WeatherCondition.clearNight
        XCTAssertTrue(condition.contains(.night))
        XCTAssertTrue(condition.contains(.moon))
        XCTAssertTrue(condition.contains(.stars))
        XCTAssertFalse(condition.contains(.day))
        XCTAssertFalse(condition.contains(.sunny))
    }

    func testThunderstormPreset() {
        let condition = WeatherCondition.thunderstorm
        XCTAssertTrue(condition.contains(.day))
        XCTAssertTrue(condition.contains(.denseClouds))
        XCTAssertTrue(condition.contains(.rainy))
        XCTAssertTrue(condition.contains(.thunder))
        XCTAssertTrue(condition.contains(.windy))
        XCTAssertFalse(condition.contains(.sunny))
        XCTAssertFalse(condition.contains(.stars))
    }

    func testHeavySnowPreset() {
        let condition = WeatherCondition.heavySnow
        XCTAssertTrue(condition.contains(.day))
        XCTAssertTrue(condition.contains(.denseClouds))
        XCTAssertTrue(condition.contains(.snowy))
        XCTAssertTrue(condition.contains(.windy))
        XCTAssertFalse(condition.contains(.rainy))
        XCTAssertFalse(condition.contains(.thunder))
    }

    func testStormyNightPreset() {
        let condition = WeatherCondition.stormyNight
        XCTAssertTrue(condition.contains(.night))
        XCTAssertTrue(condition.contains(.denseClouds))
        XCTAssertTrue(condition.contains(.rainy))
        XCTAssertTrue(condition.contains(.thunder))
        XCTAssertTrue(condition.contains(.windy))
        XCTAssertFalse(condition.contains(.day))
        XCTAssertFalse(condition.contains(.stars))
    }

    // MARK: - Display Helpers

    func testDisplayNameForSunnyDay() {
        let condition = WeatherCondition.sunnyDay
        let name = condition.displayName
        XCTAssertTrue(name.contains("Día"))
        XCTAssertTrue(name.contains("Sol"))
    }

    func testDisplayNameForClearNight() {
        let condition = WeatherCondition.clearNight
        let name = condition.displayName
        XCTAssertTrue(name.contains("Noche"))
        XCTAssertTrue(name.contains("Luna"))
        XCTAssertTrue(name.contains("Estrellas"))
    }

    func testDisplayNameForEmptyCondition() {
        let condition = WeatherCondition()
        XCTAssertEqual(condition.displayName, "Sin condición")
    }

    func testSfSymbolForThunderstorm() {
        let condition = WeatherCondition.thunderstorm
        XCTAssertEqual(condition.sfSymbol, "cloud.bolt.rain.fill")
    }

    func testSfSymbolForClearNight() {
        let condition = WeatherCondition.clearNight
        XCTAssertEqual(condition.sfSymbol, "moon.stars.fill")
    }

    // MARK: - Time of Day helpers

    func testIsDayForDayCondition() {
        XCTAssertTrue(WeatherCondition.sunnyDay.isDay)
        XCTAssertTrue(WeatherCondition.goldenSunset.isDay)
        XCTAssertTrue(WeatherCondition.goldenDawn.isDay)
    }

    func testIsNightForNightCondition() {
        XCTAssertTrue(WeatherCondition.clearNight.isNight)
        XCTAssertTrue(WeatherCondition.stormyNight.isNight)
        XCTAssertFalse(WeatherCondition.sunnyDay.isNight)
    }

    // MARK: - Atomic independence

    func testRainDoesNotRequireStorm() {
        let condition: WeatherCondition = [.day, .rainy]
        XCTAssertTrue(condition.contains(.rainy))
        XCTAssertFalse(condition.contains(.thunder))
        XCTAssertFalse(condition.contains(.windy))
        XCTAssertFalse(condition.contains(.denseClouds))
    }

    func testStarsAreIndependentOfNight() {
        let condition: WeatherCondition = [.day, .stars]
        XCTAssertTrue(condition.contains(.stars))
        XCTAssertFalse(condition.contains(.night))
    }

    func testMoonIsIndependentOfNight() {
        let condition: WeatherCondition = [.day, .moon]
        XCTAssertTrue(condition.contains(.moon))
        XCTAssertFalse(condition.contains(.night))
    }
}
