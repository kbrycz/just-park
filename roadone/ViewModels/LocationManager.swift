// LocationManager.swift

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion()
    @Published var selectedSection: Section?

    private let zoomStep: Double = 0.5

    override init() {
        super.init()
        // Set an initial region if needed
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.936, longitude: -87.656),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    func zoomIn() {
        let newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * zoomStep, longitudeDelta: region.span.longitudeDelta * zoomStep)
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: self.region.center, span: newSpan)
        }
    }

    func zoomOut() {
        let newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / zoomStep, longitudeDelta: region.span.longitudeDelta / zoomStep)
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: self.region.center, span: newSpan)
        }
    }
}
