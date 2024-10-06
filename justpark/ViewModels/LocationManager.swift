// ViewModels/LocationManager.swift

import Foundation
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MKCoordinateRegion

    @Published var selectedRoad: Road?

    private let locationManager = CLLocationManager()

    override init() {
        // Set the hardcoded user location
        let hardcodedLocation = CLLocationCoordinate2D(latitude: 41.9500, longitude: -87.6590)
        self.region = MKCoordinateRegion(
            center: hardcodedLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        super.init()
        locationManager.delegate = self

        // Simulate location update with hardcoded location
        self.locationManager(locationManager, didUpdateLocations: [CLLocation(latitude: hardcodedLocation.latitude, longitude: hardcodedLocation.longitude)])
    }

    func zoomIn() {
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
    }

    func zoomOut() {
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
    }

    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Use hardcoded user location
        if let location = locations.last {
            DispatchQueue.main.async {
                self.region.center = location.coordinate
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
}
