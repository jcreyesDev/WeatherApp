import SwiftUI
import CoreLocation

struct MainView: View {
    
    @State private var viewModel = MainViewModel(
        fetchWeatherUseCase: AppEnvironment.shared.fetchWeatherUseCase
    )

    var body: some View {
        ZStack {
            sceneLayer
            CurrentWeatherOverlay(
                viewModel: viewModel,
                onSearchTap: { viewModel.showSearch = true },
                onShowcaseTap: { viewModel.showShowcase = true }
            )
        }
        .ignoresSafeArea()
        .task {
            viewModel.startLocationTracking()
        }
        .onChange(of: viewModel.locationManager.currentLocation) {
            guard viewModel.locationManager.authorizationStatus == .authorizedWhenInUse ||
                  viewModel.locationManager.authorizationStatus == .authorizedAlways else { return }
            Task {
                if let location = viewModel.locationManager.asLocation {
                    await viewModel.selectLocation(location)
                }
            }
        }
        .sheet(isPresented: $viewModel.showSearch) {
            CitySearchView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showShowcase) {
            WeatherShowcaseView()
        }
    }

    // MARK: - Scene Layer

    private var sceneLayer: some View {
        ZStack {
            SkyBackgroundView(condition: viewModel.currentCondition)
            StarsView(condition: viewModel.currentCondition)
            MoonView(condition: viewModel.currentCondition)
            SunView(condition: viewModel.currentCondition)
            RainbowView(condition: viewModel.currentCondition)
            CloudsView(condition: viewModel.currentCondition)
            LightningView(condition: viewModel.currentCondition)
            RainView(condition: viewModel.currentCondition)
            SnowView(condition: viewModel.currentCondition)
            HailView(condition: viewModel.currentCondition)
            WindView(condition: viewModel.currentCondition)
            FogView(condition: viewModel.currentCondition)
        }
        .animation(.easeInOut(duration: 1.2), value: viewModel.currentCondition)
    }
}

// MARK: - Preview

#Preview {
    MainView()
}
