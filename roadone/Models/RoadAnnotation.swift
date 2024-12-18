// Models/RoadAnnotation.swift

import Foundation
import MapKit

class RoadAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var road: Road?

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
