// MapViewCoordinator.swift

import Foundation
import MapKit
import SwiftUI

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    var didSetInitialRegion = false

    init(_ parent: MapView) {
        self.parent = parent
    }

    // Renderer for overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? SectionPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            configurePolygonRenderer(renderer, for: overlay)
            return renderer
        } else if let polyline = overlay as? SectionPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            configurePolylineRenderer(renderer, for: overlay)
            return renderer
        }
        return MKOverlayRenderer()
    }

    // Excerpt from MapViewCoordinator
    private func configurePolygonRenderer(_ renderer: MKPolygonRenderer, for overlay: MKOverlay) {
        if let polygon = overlay as? SectionPolygon, let section = polygon.section {
            let nextDates = section.nextCleaningDates()
            if let nextDate = nextDates.first {
                let calendar = Calendar.current
                let today = Date()
                if let days = calendar.dateComponents([.day], from: today, to: nextDate).day {
                    if days <= 3 {
                        renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
                    } else if days <= 7 {
                        renderer.fillColor = UIColor.orange.withAlphaComponent(0.5)
                    } else {
                        renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.3)
                    }
                } else {
                    // Default color
                    renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.3)
                }
            } else {
                // If no upcoming/past-within-a-week date
                renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.3)
            }
        } else {
            renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
        
        renderer.strokeColor = UIColor.white.withAlphaComponent(0.5)
        renderer.lineWidth = 1.0
    }


    private func configurePolylineRenderer(_ renderer: MKPolylineRenderer, for overlay: MKOverlay) {
        // Get the section associated with this overlay
        if let polyline = overlay as? SectionPolyline, let section = polyline.section {
            let nextDates = section.nextCleaningDates()
            if let nextDate = nextDates.first {
                let calendar = Calendar.current
                let today = Date()
                if let days = calendar.dateComponents([.day], from: today, to: nextDate).day {
                    if days <= 3 {
                        // Red color
                        renderer.strokeColor = UIColor.red.withAlphaComponent(0.8)
                    } else if days <= 7 {
                        // Yellow color
                        renderer.strokeColor = UIColor.yellow.withAlphaComponent(0.8)
                    } else {
                        // Light grey color
                        renderer.strokeColor = UIColor.lightGray.withAlphaComponent(0.6)
                    }
                } else {
                    // Default color
                    renderer.strokeColor = UIColor.lightGray.withAlphaComponent(0.6)
                }
            } else {
                // Default color
                renderer.strokeColor = UIColor.lightGray.withAlphaComponent(0.6)
            }
        } else {
            // Default color
            renderer.strokeColor = UIColor.lightGray.withAlphaComponent(0.6)
        }

        renderer.lineWidth = 2.0
    }

    // Handle tap gestures
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        if let mapView = gestureRecognizer.view as? MKMapView {
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            // Iterate over overlays in reverse to check topmost overlays first
            for overlay in mapView.overlays.reversed() {
                if let renderer = mapView.renderer(for: overlay) as? MKOverlayPathRenderer {
                    let mapPoint = MKMapPoint(coordinate)
                    let point = renderer.point(for: mapPoint)
                    if renderer.path.contains(point) {
                        // Tap is inside the overlay
                        DispatchQueue.main.async {
                            if let sectionOverlay = overlay as? SectionOverlayProtocol, let section = sectionOverlay.section {
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
        DispatchQueue.main.async {
            self.parent.locationManager.region = mapView.region
        }
    }
}
