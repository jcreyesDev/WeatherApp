import Foundation

struct WeatherMapper {
    
    // MARK: - Current Weather

    func map(response: WeatherAPIResponse) -> WeatherData {
        let location = mapLocation(response.location)
        let condition = mapCondition(
            code: response.current.condition.code,
            isDay: response.current.isDay == 1
        )

        return WeatherData(
            location: location,
            condition: condition,
            temperatureCelsius: response.current.tempC,
            feelsLikeCelsius: response.current.feelslikeC,
            humidity: response.current.humidity,
            windSpeedKmh: response.current.windKph,
            precipitationMm: response.current.precipMm,
            visibilityKm: response.current.visKm,
            uvIndex: Int(response.current.uv),
            description: response.current.condition.text,
            updatedAt: Date()
        )
    }

    // MARK: - Forecast Weather

    func map(forecastResponse: WeatherAPIForecastResponse) -> [WeatherData] {
        let location = mapLocation(forecastResponse.location)

        return forecastResponse.forecast.forecastday.map { forecastDay in
            let condition = mapCondition(
                code: forecastDay.day.condition.code,
                isDay: true
            )

            return WeatherData(
                location: location,
                condition: condition,
                temperatureCelsius: forecastDay.day.avgtempC,
                feelsLikeCelsius: forecastDay.day.avgtempC,
                humidity: forecastDay.day.avghumidity,
                windSpeedKmh: forecastDay.day.maxwindKph,
                precipitationMm: forecastDay.day.totalprecipMm,
                visibilityKm: forecastDay.day.avgvisKm,
                uvIndex: Int(forecastDay.day.uvIndex),
                description: forecastDay.day.condition.text,
                updatedAt: Date()
            )
        }
    }

    // MARK: - Forecast Days

    func mapForecastDays(from response: WeatherAPIForecastResponse) -> [ForecastDay] {
        response.forecast.forecastday.compactMap { forecastDay in
            guard let date = parseDate(forecastDay.date) else { return nil }

            let condition = mapCondition(
                code: forecastDay.day.condition.code,
                isDay: true
            )

            return ForecastDay(
                date: date,
                condition: condition,
                maxTempCelsius: forecastDay.day.avgtempC,
                minTempCelsius: forecastDay.day.avgtempC,
                precipitationMm: forecastDay.day.totalprecipMm,
                humidity: forecastDay.day.avghumidity,
                uvIndex: Int(forecastDay.day.uvIndex),
                description: forecastDay.day.condition.text
            )
        }
    }

    // MARK: - Private

    private func mapLocation(_ apiLocation: WeatherAPILocation) -> Location {
        Location(
            name: apiLocation.name,
            country: apiLocation.country,
            latitude: apiLocation.lat,
            longitude: apiLocation.lon
        )
    }

    private func mapCondition(code: Int, isDay: Bool) -> WeatherCondition {
        var condition: WeatherCondition = isDay ? .day : .night

        // Agregar luna y estrellas de noche por defecto
        if !isDay {
            condition.insert(.moon)
            condition.insert(.stars)
        }

        switch code {
        case 1000:
            // Despejado
            if isDay {
                condition.insert(.sunny)
            }
        case 1003:
            // Parcialmente nublado
            condition.insert(.cloudy)
            if isDay { condition.insert(.sunny) }
            if !isDay { condition.remove(.stars) }
        case 1006, 1009:
            // Nublado / Cubierto
            condition.insert(.denseClouds)
            if !isDay {
                condition.remove(.stars)
                condition.remove(.moon)
            }
        case 1030, 1135, 1147:
            // Niebla
            condition.insert(.foggy)
            condition.insert(.cloudy)
            if !isDay { condition.remove(.stars) }
        case 1063, 1150, 1153:
            // Llovizna
            condition.insert(.drizzle)
            condition.insert(.cloudy)
            if !isDay { condition.remove(.stars) }
        case 1180, 1183, 1186, 1189:
            // Lluvia moderada
            condition.insert(.rainy)
            condition.insert(.denseClouds)
            if !isDay {
                condition.remove(.stars)
                condition.remove(.moon)
            }
        case 1192, 1195:
            // Lluvia fuerte
            condition.insert(.rainy)
            condition.insert(.windy)
            condition.insert(.denseClouds)
            if !isDay {
                condition.remove(.stars)
                condition.remove(.moon)
            }
        case 1087, 1273, 1276:
            // Tormenta eléctrica
            condition.insert(.thunder)
            condition.insert(.rainy)
            condition.insert(.windy)
            condition.insert(.denseClouds)
            if !isDay {
                condition.remove(.stars)
                condition.remove(.moon)
            }
        case 1114, 1117:
            // Ventisca de nieve
            condition.insert(.snowy)
            condition.insert(.windy)
            condition.insert(.denseClouds)
            if !isDay {
                condition.remove(.stars)
                condition.remove(.moon)
            }
        case 1066, 1210, 1213, 1216, 1219, 1222, 1225:
            // Nieve
            condition.insert(.snowy)
            condition.insert(.cloudy)
            if !isDay { condition.remove(.stars) }
        case 1237, 1261, 1264:
            // Granizo
            condition.insert(.hailing)
            condition.insert(.denseClouds)
            if !isDay {
                condition.remove(.stars)
                condition.remove(.moon)
            }
        case 1171, 1198, 1201:
            // Lluvia helada
            condition.insert(.rainy)
            condition.insert(.windy)
            condition.insert(.denseClouds)
            if !isDay {
                condition.remove(.stars)
                condition.remove(.moon)
            }
        default:
            condition.insert(.cloudy)
            if !isDay { condition.remove(.stars) }
        }

        return condition
    }

    private func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}
