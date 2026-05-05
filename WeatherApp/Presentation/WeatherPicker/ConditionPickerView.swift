import SwiftUI

struct ConditionPickerView: View {
    
    @Binding var activeCondition: WeatherCondition

    // MARK: - Time of Day

    private enum TimeOfDay: CaseIterable {
        case dawn, day, dusk, night

        var label: String {
            switch self {
            case .dawn:  return "Amanecer"
            case .day:   return "Día"
            case .dusk:  return "Ocaso"
            case .night: return "Noche"
            }
        }

        var icon: String {
            switch self {
            case .dawn:  return "sun.horizon.fill"
            case .day:   return "sun.min.fill"
            case .dusk:  return "sunset.fill"
            case .night: return "moon.fill"
            }
        }

        var condition: WeatherCondition {
            switch self {
            case .dawn:  return .dawn
            case .day:   return .day
            case .dusk:  return .dusk
            case .night: return .night
            }
        }

        static var current: TimeOfDay {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 6..<8:   return .dawn
            case 8..<19:  return .day
            case 19..<21: return .dusk
            default:      return .night
            }
        }
    }

    // MARK: - Atmospheric Conditions

    private struct AtmosphericCondition: Identifiable {
        let id = UUID()
        let label: String
        let icon: String
        let condition: WeatherCondition
    }

    private let atmosphericConditions: [AtmosphericCondition] = [
        AtmosphericCondition(label: "Sol",         icon: "sun.max.fill",        condition: .sunny),
        AtmosphericCondition(label: "Luna",        icon: "moon.stars.fill",     condition: .moon),
        AtmosphericCondition(label: "Estrellas",   icon: "sparkles",            condition: .stars),
        AtmosphericCondition(label: "Nublado",     icon: "cloud.fill",          condition: .cloudy),
        AtmosphericCondition(label: "Nubes dens.", icon: "smoke.fill",          condition: .denseClouds),
        AtmosphericCondition(label: "Llovizna",    icon: "cloud.drizzle.fill",  condition: .drizzle),
        AtmosphericCondition(label: "Lluvia",      icon: "cloud.rain.fill",     condition: .rainy),
        AtmosphericCondition(label: "Nieve",       icon: "snowflake",           condition: .snowy),
        AtmosphericCondition(label: "Granizo",     icon: "cloud.hail.fill",     condition: .hailing),
        AtmosphericCondition(label: "Niebla",      icon: "cloud.fog.fill",      condition: .foggy),
        AtmosphericCondition(label: "Viento",      icon: "wind",                condition: .windy),
        AtmosphericCondition(label: "Rayos",       icon: "bolt.fill",           condition: .thunder),
        AtmosphericCondition(label: "Arcoíris",    icon: "rainbow",             condition: .rainbow),
    ]

    @State private var selectedTimeOfDay: TimeOfDay = TimeOfDay.current

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            timeOfDayPicker
            atmosphericPicker
            clearButton
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
        .onAppear {
            applyTimeOfDay(selectedTimeOfDay, keepAtmospheric: false)
        }
    }

    // MARK: - Time of Day Picker

    private var timeOfDayPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Momento del día")
            HStack(spacing: 8) {
                ForEach(TimeOfDay.allCases, id: \.self) { time in
                    Button {
                        withAnimation(.spring(duration: 0.4)) {
                            selectedTimeOfDay = time
                            applyTimeOfDay(time, keepAtmospheric: true)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: time.icon)
                                .font(.system(size: 18))
                            Text(time.label)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(selectedTimeOfDay == time ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTimeOfDay == time
                                      ? Color.blue.opacity(0.7)
                                      : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Atmospheric Picker

    private var atmosphericPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Condiciones atmosféricas")
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 5),
                spacing: 10
            ) {
                ForEach(atmosphericConditions) { item in
                    atmosphericButton(for: item)
                }
            }
        }
    }

    private func atmosphericButton(for item: AtmosphericCondition) -> some View {
        let isDisabled = isConditionDisabled(item.condition)
        let isOn = activeCondition.contains(item.condition) && !isDisabled

        return Button {
            guard !isDisabled else { return }
            withAnimation(.spring(duration: 0.4)) {
                toggleAtmospheric(item.condition)
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                Text(item.label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundStyle(
                isDisabled ? AnyShapeStyle(.tertiary) :
                isOn ? AnyShapeStyle(Color.white) :
                AnyShapeStyle(.secondary)
            )
            .frame(width: 64, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isDisabled ? Color(.systemGray6).opacity(0.4) :
                        isOn ? Color.blue.opacity(0.7) :
                        Color(.systemGray6)
                    )
            )
            .opacity(isDisabled ? 0.4 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Clear Button

    private var clearButton: some View {
        Button {
            withAnimation(.spring(duration: 0.5)) {
                applyTimeOfDay(selectedTimeOfDay, keepAtmospheric: false)
            }
        } label: {
            Label("Limpiar condiciones", systemImage: "xmark.circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.red)
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
    }

    private func applyTimeOfDay(_ time: TimeOfDay, keepAtmospheric: Bool) {
        let atmospheric = keepAtmospheric ? currentAtmosphericConditions() : WeatherCondition()
        var newCondition = WeatherCondition()
        newCondition.insert(time.condition)

        // Defaults por momento del día
        switch time {
        case .night:
            newCondition.insert(.moon)
            newCondition.insert(.stars)
        case .day:
            newCondition.insert(.sunny)
        case .dawn, .dusk:
            newCondition.insert(.sunny)
        }

        // Reaplicamos atmosféricas válidas
        for condition in allAtmosphericConditions() {
            if atmospheric.contains(condition) && !isConditionDisabledFor(condition, timeOfDay: time) {
                newCondition.insert(condition)
            }
        }

        activeCondition = newCondition
    }

    private func toggleAtmospheric(_ condition: WeatherCondition) {
        if activeCondition.contains(condition) {
            activeCondition.remove(condition)
        } else {
            activeCondition.insert(condition)
            applyExclusions(for: condition)
        }
    }

    private func applyExclusions(for condition: WeatherCondition) {
        // Rayos excluye arcoíris
        if condition.contains(.thunder) {
            activeCondition.remove(.rainbow)
            activeCondition.remove(.foggy)
        }
        // Arcoíris excluye rayos
        if condition.contains(.rainbow) {
            activeCondition.remove(.thunder)
        }
        // Nubes densas quitan estrellas y luna
        if condition.contains(.denseClouds) {
            activeCondition.remove(.stars)
            activeCondition.remove(.moon)
        }
        // Noche: sol no permitido
        if selectedTimeOfDay == .night {
            activeCondition.remove(.sunny)
        }
        // Día: luna y estrellas no permitidas
        if selectedTimeOfDay == .day {
            activeCondition.remove(.moon)
            activeCondition.remove(.stars)
        }
    }

    private func isConditionDisabled(_ condition: WeatherCondition) -> Bool {
        isConditionDisabledFor(condition, timeOfDay: selectedTimeOfDay)
    }

    private func isConditionDisabledFor(_ condition: WeatherCondition, timeOfDay: TimeOfDay) -> Bool {
        switch timeOfDay {
        case .night:
            if condition == .sunny { return true }
        case .day:
            if condition == .moon || condition == .stars { return true }
        case .dawn, .dusk:
            if condition == .moon || condition == .stars { return true }
        }

        // Arcoíris requiere lluvia o llovizna
        if condition == .rainbow {
            let hasPrecip = activeCondition.contains(.rainy) || activeCondition.contains(.drizzle)
            let isDayTime = timeOfDay == .day || timeOfDay == .dawn || timeOfDay == .dusk
            if !hasPrecip || !isDayTime { return true }
        }

        // Nubes densas activas deshabilitan luna, estrellas
        if activeCondition.contains(.denseClouds) {
            if condition == .stars || condition == .moon { return true }
        }

        // Rayos activos deshabilitan arcoíris y niebla
        if activeCondition.contains(.thunder) {
            if condition == .rainbow || condition == .foggy { return true }
        }

        return false
    }

    private func currentAtmosphericConditions() -> WeatherCondition {
        var result = WeatherCondition()
        for condition in allAtmosphericConditions() {
            if activeCondition.contains(condition) {
                result.insert(condition)
            }
        }
        return result
    }

    private func allAtmosphericConditions() -> [WeatherCondition] {
        atmosphericConditions.map { $0.condition }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "1b2d4a").ignoresSafeArea()
        ConditionPickerView(activeCondition: .constant(.clearNight))
    }
}
