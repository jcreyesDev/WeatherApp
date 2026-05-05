import Foundation

struct Location: Equatable {
    
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double

    var displayName: String {
        "\(name), \(country)"
    }
}
