import Foundation
import Observation

@Observable
final class CitySearchViewModel {
    
    // MARK: - State

    var query: String = ""
    var results: [Location] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let fetchWeatherUseCase: FetchWeatherUseCase
    private var searchTask: Task<Void, Never>?
    private var debounceTask: Task<Void, Never>?

    init(fetchWeatherUseCase: FetchWeatherUseCase = AppEnvironment.shared.fetchWeatherUseCase) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
    }

    // MARK: - Actions

    func scheduleSearch() {
        debounceTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            isLoading = false
            return
        }

        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await search()
        }
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        searchTask?.cancel()
        searchTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil

            do {
                let found = try await fetchWeatherUseCase.executeSearch(query: trimmed)
                guard !Task.isCancelled else { return }
                results = found
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                results = []
            }

            isLoading = false
        }

        await searchTask?.value
    }
}
