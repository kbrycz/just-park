// Views/MapViewCoordinator.swift

import Foundation
import MapKit
import SwiftUI

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    init(_ parent: MapView) {
        self.parent = parent
    }

    // Renderer for overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon, polygon.title == "SectionOverlay" {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 2
            renderer.alpha = 0.5
            // Removed invalid properties:
            // renderer.isOpaque = false
            // renderer.isUserInteractionEnabled = false
            return renderer
        }
        return MKOverlayRenderer()
    }

    // Handle tap gestures
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        if let mapView = gestureRecognizer.view as? MKMapView {
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            if let overlays = mapView.overlays as? [MKPolygon] {
                for overlay in overlays {
                    let renderer = MKPolygonRenderer(polygon: overlay)
                    let mapPoint = MKMapPoint(coordinate)
                    let point = renderer.point(for: mapPoint)
                    if renderer.path.contains(point) {
                        // Tap is inside the polygon
                        DispatchQueue.main.async {
                            if let section = self.parent.section {
                                self.parent.locationManager.selectedSection = section
                            }
                        }
                        break
                    }
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Update the LocationManager's region to match the map view's region
        parent.locationManager.region = mapView.region
    }
}
