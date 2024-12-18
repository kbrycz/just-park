// Models/Road.swift

import Foundation
import MapKit

class Road: Identifiable, ObservableObject {
    let id: Int
    let name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

class RoadOverlay: MKPolyline {
    weak var road: Road?
}
