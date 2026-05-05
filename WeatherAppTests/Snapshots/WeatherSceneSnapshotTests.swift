import XCTest
import SnapshotTesting
import SwiftUI
@testable import WeatherApp

final class WeatherSceneSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Uncomment to regenerate snapshot references
//         withSnapshotTesting(record: .all) {}
    }

    // MARK: - Sky Background

    func testSkyBackgroundSunnyDay() {
        let view = SkyBackgroundView(condition: .sunnyDay)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    func testSkyBackgroundClearNight() {
        let view = SkyBackgroundView(condition: .clearNight)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    func testSkyBackgroundThunderstorm() {
        let view = SkyBackgroundView(condition: .thunderstorm)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    func testSkyBackgroundHeavySnow() {
        let view = SkyBackgroundView(condition: .heavySnow)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    func testSkyBackgroundFoggyMorning() {
        let view = SkyBackgroundView(condition: .foggyMorning)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    func testSkyBackgroundGoldenSunset() {
        let view = SkyBackgroundView(condition: .goldenSunset)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    func testSkyBackgroundStormyNight() {
        let view = SkyBackgroundView(condition: .stormyNight)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    // MARK: - Main View Overlay

    func testMainViewSunnyDay() {
        let viewModel = MainViewModel(
            fetchWeatherUseCase: AppEnvironment.mock(.mock)
        )
        let view = MainViewSnapshot(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    func testMainViewStormyNight() {
        let viewModel = MainViewModel(
            fetchWeatherUseCase: AppEnvironment.mock(.mockStorm)
        )
        let view = MainViewSnapshot(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    func testMainViewHeavySnow() {
        let viewModel = MainViewModel(
            fetchWeatherUseCase: AppEnvironment.mock(.mockSnow)
        )
        let view = MainViewSnapshot(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }

    // MARK: - Forecast Day Card

    func testForecastDayCardToday() {
        let card = ForecastDayCard(
            day: ForecastDay.mockForecast[0],
            isToday: true
        )
        let vc = UIHostingController(rootView: card)
        vc.view.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
        assertSnapshot(of: vc, as: .image)
    }

    func testForecastDayCardRegular() {
        let card = ForecastDayCard(
            day: ForecastDay.mockForecast[1],
            isToday: false
        )
        let vc = UIHostingController(rootView: card)
        vc.view.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
        assertSnapshot(of: vc, as: .image)
    }

    func testForecastDayCardWithRain() {
        let card = ForecastDayCard(
            day: ForecastDay.mockForecast[2],
            isToday: false
        )
        let vc = UIHostingController(rootView: card)
        vc.view.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
        assertSnapshot(of: vc, as: .image)
    }
}

// MARK: - Snapshot Helper

private struct MainViewSnapshot: View {

    let viewModel: MainViewModel

    var body: some View {
        ZStack {
            SkyBackgroundView(condition: viewModel.currentCondition)
            CurrentWeatherOverlay(
                viewModel: viewModel,
                onSearchTap: {},
                onShowcaseTap: {}
            )
        }
        .ignoresSafeArea()
    }
}
