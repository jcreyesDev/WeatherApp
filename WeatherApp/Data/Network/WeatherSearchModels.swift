import Foundation

// MARK: - Search Response

struct WeatherSearchResponse: Codable {
    
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}
