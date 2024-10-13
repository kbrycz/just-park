// Views/RoadMapViewCoordinator.swift

import Foundation
import MapKit
import SwiftUI

class RoadMapViewCoordinator: NSObject, MKMapViewDelegate {
    var parent: RoadMapView

    init(_ parent: RoadMapView) {
        self.parent = parent
    }

    // Renderer for road overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? RoadOverlay {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.red.withAlphaComponent(0.7)
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
}
