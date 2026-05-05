import Foundation

// MARK: - Current Weather Response
struct WeatherAPIResponse: Codable {
    
    let location: WeatherAPILocation
    let current: WeatherAPICurrent
}

// MARK: - Location
struct WeatherAPILocation: Codable {
    
    let name: String
    let country: String
    let lat: Double
    let lon: Double
}

// MARK: - Current
struct WeatherAPICurrent: Codable {
    
    let tempC: Double
    let feelslikeC: Double
    let humidity: Int
    let windKph: Double
    let precipMm: Double
    let visKm: Double
    let uv: Double
    let isDay: Int
    let condition: WeatherAPICondition

    enum CodingKeys: String, CodingKey {
        case tempC       = "temp_c"
        case feelslikeC  = "feelslike_c"
        case humidity
        case windKph     = "wind_kph"
        case precipMm    = "precip_mm"
        case visKm       = "vis_km"
        case uv
        case isDay       = "is_day"
        case condition
    }
}

// MARK: - Condition
struct WeatherAPICondition: Codable {
    
    let text: String
    let code: Int
}

// MARK: - Forecast Response
struct WeatherAPIForecastResponse: Codable {
    
    let location: WeatherAPILocation
    let forecast: WeatherAPIForecast
}

struct WeatherAPIForecast: Codable {
    
    let forecastday: [WeatherAPIForecastDay]
}

struct WeatherAPIForecastDay: Codable {
    
    let date: String
    let day: WeatherAPIDay
}

struct WeatherAPIDay: Codable {
    
    let avgtempC: Double
    let maxwindKph: Double
    let totalprecipMm: Double
    let avgvisKm: Double
    let avghumidity: Int
    let uvIndex: Double
    let condition: WeatherAPICondition

    enum CodingKeys: String, CodingKey {
        case avgtempC       = "avgtemp_c"
        case maxwindKph     = "maxwind_kph"
        case totalprecipMm  = "totalprecip_mm"
        case avgvisKm       = "avgvis_km"
        case avghumidity
        case uvIndex        = "uv"
        case condition
    }
}
