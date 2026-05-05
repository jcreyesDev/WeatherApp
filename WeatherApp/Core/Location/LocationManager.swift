import Foundation
import CoreLocation
import Observation

@Observable
final class LocationManager: NSObject {
    
    // MARK: - State

    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    var isLoading: Bool = false

    // MARK: - Private

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Actions

    func requestLocation() {
        isLoading = true
        errorMessage = nil

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Permiso de ubicación denegado. Activalo en Ajustes."
            isLoading = false
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }

    var asLocation: Location? {
        guard let location = currentLocation else { return nil }
        return Location(
            name: "Mi ubicación",
            country: "",
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        isLoading = false
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Permiso de ubicación denegado. Activalo en Ajustes."
            isLoading = false
        default:
            break
        }
    }
}
