import CoreLocation
import Combine

/// Detects which UTS campus building a student is near, so Report Lost/Found
/// forms can suggest the location automatically instead of requiring manual
/// entry every time — a real use of an iOS-only capability a website
/// couldn't offer in the same way.
final class CampusLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var suggestedBuilding: String?

    private let manager = CLLocationManager()

    /// Known UTS Broadway campus buildings. Coordinates are approximate —
    /// close enough for suggesting "you're probably near this building"
    /// rather than precise navigation.
    private let knownBuildings: [(name: String, coordinate: CLLocationCoordinate2D)] = [
        ("UTS Tower (Building 1)", CLLocationCoordinate2D(latitude: -33.8833, longitude: 151.1995)),
        ("UTS Library (Building 11)", CLLocationCoordinate2D(latitude: -33.8838, longitude: 151.2003)),
        ("Building 2", CLLocationCoordinate2D(latitude: -33.8828, longitude: 151.1989)),
        ("Building 4", CLLocationCoordinate2D(latitude: -33.8842, longitude: 151.1998)),
        ("Building 5", CLLocationCoordinate2D(latitude: -33.8845, longitude: 151.2008)),
    ]

    /// Only suggest a building if the student is within this many metres
    private let maxSuggestionDistanceMeters: CLLocationDistance = 300

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let current = locations.last else { return }

        let nearest = knownBuildings.min { lhs, rhs in
            let lhsLocation = CLLocation(latitude: lhs.coordinate.latitude, longitude: lhs.coordinate.longitude)
            let rhsLocation = CLLocation(latitude: rhs.coordinate.latitude, longitude: rhs.coordinate.longitude)
            return current.distance(from: lhsLocation) < current.distance(from: rhsLocation)
        }

        if let nearest {
            let nearestLocation = CLLocation(latitude: nearest.coordinate.latitude, longitude: nearest.coordinate.longitude)
            if current.distance(from: nearestLocation) <= maxSuggestionDistanceMeters {
                suggestedBuilding = nearest.name
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}
