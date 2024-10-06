// Views/MapViewCoordinator.swift

import Foundation
import MapKit
import SwiftUI
import Contacts

class MapViewCoordinator: NSObject {
    var parent: MapView
    var locationManager: LocationManager

    // Keep track of the temporary annotation
    var selectedAnnotation: MKPointAnnotation?

    init(_ parent: MapView, locationManager: LocationManager) {
        self.parent = parent
        self.locationManager = locationManager
    }
}
