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
        if let polygon = overlay as? SectionOverlay {
            let renderer = MKPolygonRenderer(polygon: polygon)

            // Get the section from the overlay
            if let section = polygon.section {
                let nextDates = section.nextCleaningDates()
                if let nextDate = nextDates.first {
                    let calendar = Calendar.current
                    let today = Date()
                    if let days = calendar.dateComponents([.day], from: today, to: nextDate).day {
                        if days <= 3 {
                            // Red color
                            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
                        } else if days <= 7 {
                            // Yellow color
                            renderer.fillColor = UIColor.yellow.withAlphaComponent(0.5)
                        } else {
                            // Light grey color
                            renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.3)
                        }
                    } else {
                        // If date components could not be calculated, default to light grey
                        renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.3)
                    }
                } else {
                    // No upcoming cleaning dates, default to light grey
                    renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.3)
                }
            } else {
                // No section, default to light grey
                renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.3)
            }

            // Remove the X by setting the stroke color to clear and line width to zero
            renderer.strokeColor = UIColor.clear
            renderer.lineWidth = 0
            renderer.alpha = 1.0

            return renderer
        }
        return MKOverlayRenderer()
    }

    // Handle tap gestures
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        if let mapView = gestureRecognizer.view as? MKMapView {
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            if let overlays = mapView.overlays as? [SectionOverlay] {
                for overlay in overlays {
                    let renderer = MKPolygonRenderer(polygon: overlay)
                    let mapPoint = MKMapPoint(coordinate)
                    let point = renderer.point(for: mapPoint)
                    if renderer.path.contains(point) {
                        // Tap is inside the polygon
                        DispatchQueue.main.async {
                            if let section = overlay.section {
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
