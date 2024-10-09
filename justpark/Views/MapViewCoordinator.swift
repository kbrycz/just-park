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
        if let roadOverlay = overlay as? RoadOverlay {
            let renderer = MKPolylineRenderer(polyline: roadOverlay)

            if let road = roadOverlay.road {
                let status = road.getStatus() // Use getStatus() method

                switch status {
                case "red":
                    renderer.strokeColor = UIColor.red.withAlphaComponent(0.7)
                case "yellow":
                    renderer.strokeColor = UIColor.yellow.withAlphaComponent(0.7)
                case "green":
                    renderer.strokeColor = UIColor.green.withAlphaComponent(0.7)
                default:
                    renderer.strokeColor = UIColor.gray.withAlphaComponent(0.7)
                }
            } else {
                renderer.strokeColor = UIColor.gray.withAlphaComponent(0.7)
            }

            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }

    // Handle annotation views
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is RoadAnnotation else { return nil }

        let identifier = "RoadAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }

        // Make the annotation view invisible but with a larger touch area
        annotationView?.isEnabled = true
        annotationView?.alpha = 0.001
        annotationView?.frame.size = CGSize(width: 44, height: 44) // Increase touch area
        annotationView?.centerOffset = CGPoint(x: 0, y: 0)

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let roadAnnotation = view.annotation as? RoadAnnotation,
           let road = roadAnnotation.road {
            DispatchQueue.main.async {
                self.parent.locationManager.selectedRoad = road
            }
        }
        // Deselect the annotation to allow re-selection
        mapView.deselectAnnotation(view.annotation, animated: false)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Update the LocationManager's region to match the map view's region
        parent.locationManager.region = mapView.region
    }
}
