import SwiftUI

struct CurrentWeatherOverlay: View {
    
    let viewModel: MainViewModel
    let onSearchTap: () -> Void
    let onShowcaseTap: () -> Void

    var body: some View {
        VStack {
            topBar
            Spacer()
            bottomContent
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 48)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.locationName)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(viewModel.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            HStack(spacing: 12) {
                // Search button
                Button {
                    onSearchTap()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial, in: Circle())
                }

                // Showcase button
                Button {
                    onShowcaseTap()
                } label: {
                    Image(systemName: "cloud.sun.rain")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial, in: Circle())
                }

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }

    // MARK: - Bottom Content

    private var bottomContent: some View {
        VStack(spacing: 16) {
            temperatureDisplay
            statsRow

            if !viewModel.forecastDays.isEmpty {
                ForecastScrollView(days: viewModel.forecastDays)
            }

            if viewModel.hasError {
                errorBanner
            }
        }
    }

    // MARK: - Temperature

    private var temperatureDisplay: some View {
        VStack(spacing: 4) {
            Text(viewModel.temperature)
                .font(.system(size: 80, weight: .thin, design: .rounded))
                .foregroundStyle(.white)
            Text(viewModel.feelsLike)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statItem(icon: "humidity.fill",      value: viewModel.humidity)
            statItem(icon: "wind",               value: viewModel.windSpeed)
            statItem(icon: "eye.fill",           value: viewModel.visibility)
            statItem(icon: "sun.max.circle.fill", value: viewModel.uvIndex)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.25), lineWidth: 0.5)
                )
        )
    }

    private func statItem(icon: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.9))
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Error Banner

    private var errorBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(viewModel.errorMessage ?? "Error desconocido")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Button("Reintentar") {
                Task { await viewModel.retry() }
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "1b2d4a").ignoresSafeArea()
        CurrentWeatherOverlay(
            viewModel: MainViewModel(
                fetchWeatherUseCase: AppEnvironment.mockFull()
            ),
            onSearchTap: {},
            onShowcaseTap: {}
        )
    }
}
