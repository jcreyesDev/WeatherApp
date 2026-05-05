import Foundation

struct WeatherCondition: OptionSet, Hashable {
    let rawValue: Int

    // MARK: - Time of Day (fondos — mutuamente excluyentes)
    static let day      = WeatherCondition(rawValue: 1 << 0)
    static let night    = WeatherCondition(rawValue: 1 << 1)
    static let dawn     = WeatherCondition(rawValue: 1 << 2)  // amanecer
    static let dusk     = WeatherCondition(rawValue: 1 << 3)  // ocaso/atardecer

    // MARK: - Sky Elements (atómicos)
    static let sunny        = WeatherCondition(rawValue: 1 << 4)   // sol visible
    static let moon         = WeatherCondition(rawValue: 1 << 5)   // luna visible
    static let stars        = WeatherCondition(rawValue: 1 << 6)   // estrellas visibles
    static let rainbow      = WeatherCondition(rawValue: 1 << 7)   // arcoíris

    // MARK: - Cloud Elements (atómicos)
    static let cloudy       = WeatherCondition(rawValue: 1 << 8)   // nubes normales
    static let denseClouds  = WeatherCondition(rawValue: 1 << 9)   // nubes oscuras densas
    static let foggy        = WeatherCondition(rawValue: 1 << 10)  // niebla

    // MARK: - Precipitation (atómicos)
    static let drizzle      = WeatherCondition(rawValue: 1 << 11)  // llovizna
    static let rainy        = WeatherCondition(rawValue: 1 << 12)  // lluvia
    static let snowy        = WeatherCondition(rawValue: 1 << 13)  // nieve
    static let hailing      = WeatherCondition(rawValue: 1 << 14)  // granizo

    // MARK: - Atmospheric (atómicos)
    static let windy        = WeatherCondition(rawValue: 1 << 15)  // viento
    static let thunder      = WeatherCondition(rawValue: 1 << 16)  // rayos

    // MARK: - Presets (combinaciones atómicas)

    // Día
    static let sunnyDay: WeatherCondition           = [.day, .sunny]
    static let cloudyDay: WeatherCondition          = [.day, .cloudy]
    static let lightRain: WeatherCondition          = [.day, .cloudy, .drizzle]
    static let heavyRain: WeatherCondition          = [.day, .denseClouds, .rainy, .windy]
    static let thunderstorm: WeatherCondition       = [.day, .denseClouds, .rainy, .thunder, .windy]
    static let heavySnow: WeatherCondition          = [.day, .denseClouds, .snowy, .windy]
    static let foggyMorning: WeatherCondition       = [.day, .cloudy, .foggy]

    // Amanecer / Ocaso
    static let goldenSunset: WeatherCondition       = [.dusk, .sunny]
    static let goldenDawn: WeatherCondition         = [.dawn, .sunny]

    // Noche
    static let clearNight: WeatherCondition         = [.night, .moon, .stars]
    static let cloudyNight: WeatherCondition        = [.night, .cloudy, .moon]
    static let stormyNight: WeatherCondition        = [.night, .denseClouds, .rainy, .thunder, .windy]
    static let snowyNight: WeatherCondition         = [.night, .denseClouds, .snowy]

    // Especiales
    static let rainbowAfterRain: WeatherCondition   = [.day, .cloudy, .rainbow]
    static let blizzard: WeatherCondition           = [.day, .denseClouds, .snowy, .windy, .foggy]
    static let foggyNight: WeatherCondition         = [.night, .moon, .foggy]
}

// MARK: - Display Helpers

extension WeatherCondition {

    var displayName: String {
        var parts: [String] = []
        if contains(.night)       { parts.append("Noche") }
        if contains(.dawn)        { parts.append("Amanecer") }
        if contains(.dusk)        { parts.append("Ocaso") }
        if contains(.day)         { parts.append("Día") }
        if contains(.sunny)       { parts.append("Sol") }
        if contains(.moon)        { parts.append("Luna") }
        if contains(.stars)       { parts.append("Estrellas") }
        if contains(.cloudy)      { parts.append("Nublado") }
        if contains(.denseClouds) { parts.append("Nubes densas") }
        if contains(.foggy)       { parts.append("Niebla") }
        if contains(.drizzle)     { parts.append("Llovizna") }
        if contains(.rainy)       { parts.append("Lluvia") }
        if contains(.hailing)     { parts.append("Granizo") }
        if contains(.snowy)       { parts.append("Nieve") }
        if contains(.windy)       { parts.append("Viento") }
        if contains(.thunder)     { parts.append("Rayos") }
        if contains(.rainbow)     { parts.append("Arcoíris") }
        return parts.isEmpty ? "Sin condición" : parts.joined(separator: " · ")
    }

    var sfSymbol: String {
        if contains(.thunder)     { return "cloud.bolt.rain.fill" }
        if contains(.denseClouds) && contains(.rainy) { return "cloud.heavyrain.fill" }
        if contains(.snowy)       { return "snowflake" }
        if contains(.hailing)     { return "cloud.hail.fill" }
        if contains(.rainy)       { return "cloud.rain.fill" }
        if contains(.drizzle)     { return "cloud.drizzle.fill" }
        if contains(.foggy)       { return "cloud.fog.fill" }
        if contains(.rainbow)     { return "rainbow" }
        if contains(.denseClouds) { return "smoke.fill" }
        if contains(.cloudy)      { return "cloud.fill" }
        if contains(.sunny)       { return "sun.max.fill" }
        if contains(.moon)        { return "moon.stars.fill" }
        if contains(.stars)       { return "sparkles" }
        if contains(.dawn)        { return "sun.horizon.fill" }
        if contains(.dusk)        { return "sun.horizon.fill" }
        if contains(.night)       { return "moon.fill" }
        return "cloud.sun.fill"
    }

    // MARK: - Time of Day helpers

    var isDay: Bool {
        contains(.day) || contains(.dawn) || contains(.dusk)
    }

    var isNight: Bool {
        contains(.night)
    }

    var timeOfDay: WeatherCondition {
        if contains(.night) { return .night }
        if contains(.dawn)  { return .dawn }
        if contains(.dusk)  { return .dusk }
        return .day
    }
}
