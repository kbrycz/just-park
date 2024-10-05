// Views/MapViewCoordinator.swift

import Foundation
import MapKit
import SwiftUI

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    var locationManager: LocationManager

    init(_ parent: MapView, locationManager: LocationManager) {
        self.parent = parent
        self.locationManager = locationManager
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let roadOverlay = overlay as? RoadOverlay {
            let renderer = MKPolylineRenderer(polyline: roadOverlay)
            
            if let road = roadOverlay.road {
                print("Found road: \(road.name) with status: \(road.status())")
                let status = road.status()
                
                switch status {
                case "red":
                    renderer.strokeColor = UIColor.red.withAlphaComponent(0.7)
                case "yellow":
                    renderer.strokeColor = UIColor.yellow.withAlphaComponent(0.7)
                case "clear":
                    renderer.strokeColor = UIColor.green.withAlphaComponent(0.1) // Very transparent
                default:
                    renderer.strokeColor = UIColor.gray.withAlphaComponent(0.7)
                }
            } else {
                print("No associated road found for overlay")
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
                self.locationManager.selectedRoad = road
            }
        }
        // Deselect the annotation to allow re-selection
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
}
