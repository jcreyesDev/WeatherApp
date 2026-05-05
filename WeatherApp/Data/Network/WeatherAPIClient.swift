import Foundation

enum WeatherAPIError: Error, LocalizedError {
    
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
            case .invalidURL:
                return "URL inválida"
            case .invalidResponse:
                return "Respuesta inválida del servidor"
            case .httpError(let code):
                return "Error HTTP: \(code)"
            case .decodingError(let error):
                return "Error al procesar datos: \(error.localizedDescription)"
            case .unknown(let error):
                return "Error desconocido: \(error.localizedDescription)"
        }
    }
}

final class WeatherAPIClient {
    
    private let apiKey: String
    private let baseURL = "https://api.weatherapi.com/v1"
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherAPIResponse {
        let urlString = "\(baseURL)/current.json?key=\(apiKey)&q=\(lat),\(lon)&aqi=no&lang=es"
        return try await performRequest(urlString: urlString)
    }

    func fetchForecast(lat: Double, lon: Double, days: Int) async throws -> WeatherAPIForecastResponse {
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=\(days)&aqi=no"
        
        return try await performRequest(urlString: urlString)
    }
    
    func searchCities(query: String) async throws -> [WeatherSearchResponse] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search.json?key=\(apiKey)&q=\(encoded)&limit=5"
        return try await performRequest(urlString: urlString)
    }

    func fetchForecastDays(lat: Double, lon: Double, days: Int) async throws -> WeatherAPIForecastResponse {
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(lat),\(lon)&days=\(days)&aqi=no&lang=es"
        return try await performRequest(urlString: urlString)
    }

    // MARK: - Private
    private func performRequest<T: Codable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw WeatherAPIError.invalidURL
        }

        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherAPIError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            
            return decoded
        } catch {
            throw WeatherAPIError.decodingError(error)
        }
    }
}
