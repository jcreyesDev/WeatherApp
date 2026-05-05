import Foundation
import Observation

@Observable
final class WeatherShowcaseViewModel {
    
    // MARK: - State

    var selectedCondition: WeatherCondition? = nil
    var selectedTitle: String = ""
    var showDetail: Bool = false
    var showCustomScene: Bool = false

    // MARK: - Data

    let showcaseItems: [ShowcaseItem] = [
        ShowcaseItem(title: "☀️ Soleado",           condition: .sunnyDay),
        ShowcaseItem(title: "🌤 Nublado",           condition: .cloudyDay),
        ShowcaseItem(title: "🌦 Lluvia leve",       condition: .lightRain),
        ShowcaseItem(title: "🌧 Lluvia fuerte",     condition: .heavyRain),
        ShowcaseItem(title: "⛈ Tormenta",           condition: .thunderstorm),
        ShowcaseItem(title: "🌨 Nevada",            condition: .heavySnow),
        ShowcaseItem(title: "🌫 Niebla",            condition: .foggyMorning),
        ShowcaseItem(title: "🌅 Atardecer",         condition: .goldenSunset),
        ShowcaseItem(title: "🌄 Amanecer",          condition: .goldenDawn),
        ShowcaseItem(title: "🌙 Noche despejada",   condition: .clearNight),
        ShowcaseItem(title: "☁️ Noche nublada",     condition: .cloudyNight),
        ShowcaseItem(title: "🌩 Tormenta nocturna", condition: .stormyNight),
        ShowcaseItem(title: "❄️ Nieve nocturna",    condition: .snowyNight),
        ShowcaseItem(title: "🧊 Granizo",           condition: [.day, .denseClouds, .hailing, .windy]),
        ShowcaseItem(title: "🌈 Arcoíris",          condition: .rainbowAfterRain),
        ShowcaseItem(title: "🌪 Ventisca",          condition: .blizzard),
        ShowcaseItem(title: "🌁 Noche con niebla",  condition: .foggyNight),
    ]

    // MARK: - Actions

    func selectCondition(_ item: ShowcaseItem) {
        selectedCondition = item.condition
        selectedTitle = item.title
        showDetail = true
    }

    func clearSelection() {
        showDetail = false
        selectedCondition = nil
        selectedTitle = ""
    }
}

// MARK: - ShowcaseItem

struct ShowcaseItem: Identifiable {
    
    let id = UUID()
    let title: String
    let condition: WeatherCondition
}
