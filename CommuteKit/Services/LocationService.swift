import Foundation
import CoreLocation
import os

@MainActor @Observable
public final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let logger = Logger(subsystem: "com.commuteassistant", category: "Location")

    public var currentLocation: CLLocation?
    public var authorizationStatus: CLAuthorizationStatus = .notDetermined

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    public func startMonitoringSignificantLocationChanges() {
        manager.startMonitoringSignificantLocationChanges()
    }

    public func stopMonitoring() {
        manager.stopMonitoringSignificantLocationChanges()
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            currentLocation = location
        }
    }

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            logger.error("Location error: \(error)")
        }
    }
}
