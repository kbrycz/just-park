// ViewModels/LocationManager.swift

import Foundation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.936, longitude: -87.656), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @Published var selectedSection: Section?

    override init() {
        super.init()
    }

    func zoomIn() {
        let newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 0.5, longitudeDelta: region.span.longitudeDelta * 0.5)
        region.span = newSpan
    }

    func zoomOut() {
        let newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2.0, longitudeDelta: region.span.longitudeDelta * 2.0)
        region.span = newSpan
    }
}
