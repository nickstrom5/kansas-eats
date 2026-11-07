import CoreLocation
import Observation
import UIKit

/// "Near me" sorting. Asks for when-in-use permission only when a list is sorted by distance or "My location" is tapped; the location never leaves the device.
@MainActor
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var location: CLLocation?
    private(set) var status: CLAuthorizationStatus = .notDetermined
    /// no fix within 12 seconds, or Core Location reported an error
    private(set) var failed = false
    private var timeout: Task<Void, Never>?
    /// when the current request started: a fix from before it is a cached one (from launch, or before a drive) and doesn't count
    private var askedAt = Date.distantPast

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        status = manager.authorizationStatus
    }

    var isDenied: Bool { status == .denied || status == .restricted }

    /// Every place is in Kansas, so a reader elsewhere (an App Reviewer in California, say) gets told rather than an empty map.
    /// A coarse outline of the state (Idaho's lesson: a bounding box would count Calumet City, Louisville and Cincinnati),
    /// drawn a little outside the line so the river and lake shores count as inside.
    var isOutsideKansas: Bool {
        guard let c = location?.coordinate else { return false }
        return !KansasOutline.contains(c)
    }

    /// Once location is off for the app, iOS won't ask again; the app's page in Settings is the only way back.
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
    }

    func request() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: locate()
        default: break
        }
    }

    private func locate() {
        failed = false
        let asked = Date()
        askedAt = asked
        manager.requestLocation()
        timeout?.cancel()
        timeout = Task { [weak self] in
            try? await Task.sleep(for: .seconds(12))
            guard let self, !Task.isCancelled else { return }
            if (self.location?.timestamp ?? .distantPast) < asked { self.failed = true }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ m: CLLocationManager) {
        let s = m.authorizationStatus
        Task { @MainActor in
            self.status = s
            if s == .authorizedWhenInUse || s == .authorizedAlways { self.locate() }
        }
    }

    nonisolated func locationManager(_ m: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let l = locations.last else { return }
        Task { @MainActor in
            // "My location" needs a fresh fix on every tap: a cached one from before the request would put you back where you were
            guard l.timestamp >= self.askedAt.addingTimeInterval(-2) else { return }
            self.location = l; self.failed = false; self.timeout?.cancel()
        }
    }

    nonisolated func locationManager(_ m: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in if self.location == nil { self.failed = true } }
    }
}

extension CLLocation {
    /// "0.4 mi", "12 mi", "1,012 mi" (an App Reviewer in California is a thousand miles out)
    func milesText(to other: CLLocation) -> String {
        let mi = distance(from: other) / 1609.344
        return (mi < 10 ? mi.formatted(.number.precision(.fractionLength(1))) : Int(mi.rounded()).formatted()) + " mi"
    }
}

/// A coarse Kansas outline (longitude, latitude), about 400 m outside the Overture land outline but never over a neighbour's land
/// (buffer 0.004°, minus the neighbours buffered 0.0015°, simplify 0.006°). Wichita, Kansas City (Kansas), Leawood, Elwood, Baxter
/// Springs, Liberal, Goodland and White Cloud are inside; Kansas City, St. Joseph and Joplin (Missouri), Miami (Oklahoma), Burlington
/// (Colorado) and Falls City (Nebraska) are not.
enum KansasOutline {
    static let rings: [[(Double, Double)]] = [
        [(-102.041, 36.995), (-102.05, 40.002), (-95.309, 39.999), (-95.306, 39.986), (-95.249, 39.946), (-95.206, 39.938),
         (-95.204, 39.904), (-95.148, 39.904), (-95.142, 39.881), (-95.129, 39.872), (-95.082, 39.86), (-95.035, 39.864),
         (-95.023, 39.891), (-95.006, 39.899), (-94.952, 39.899), (-94.931, 39.888), (-94.941, 39.851), (-94.917, 39.835),
         (-94.888, 39.832), (-94.878, 39.81), (-94.89, 39.794), (-94.932, 39.789), (-94.938, 39.775), (-94.911, 39.756),
         (-94.872, 39.772), (-94.86, 39.758), (-94.863, 39.743), (-94.896, 39.726), (-94.944, 39.746), (-94.964, 39.743),
         (-94.972, 39.732), (-94.974, 39.686), (-95.028, 39.667), (-95.056, 39.628), (-95.052, 39.589), (-95.066, 39.578),
         (-95.104, 39.579), (-95.114, 39.562), (-95.112, 39.544), (-95.09, 39.52), (-95.056, 39.501), (-95.043, 39.466),
         (-94.988, 39.444), (-94.973, 39.419), (-94.95, 39.409), (-94.941, 39.387), (-94.885, 39.387), (-94.883, 39.371),
         (-94.911, 39.353), (-94.908, 39.314), (-94.886, 39.283), (-94.833, 39.256), (-94.828, 39.239), (-94.836, 39.221),
         (-94.827, 39.211), (-94.783, 39.205), (-94.765, 39.179), (-94.741, 39.169), (-94.678, 39.183), (-94.663, 39.177),
         (-94.654, 39.153), (-94.609, 39.16), (-94.59, 39.15), (-94.61, 39.117), (-94.619, 37.0), (-100.089, 37.004),
         (-102.041, 36.995)]]

    static func contains(_ c: CLLocationCoordinate2D) -> Bool { rings.contains { contains(c, ring: $0) } }

    /// Ray casting: a point is inside when a ray east of it crosses the outline an odd number of times.
    static func contains(_ c: CLLocationCoordinate2D, ring: [(Double, Double)]) -> Bool {
        var inside = false
        var j = ring.count - 1
        for i in 0..<ring.count {
            let (xi, yi) = ring[i], (xj, yj) = ring[j]
            if (yi > c.latitude) != (yj > c.latitude) && c.longitude < (xj - xi) * (c.latitude - yi) / (yj - yi) + xi { inside.toggle() }
            j = i
        }
        return inside
    }
}
