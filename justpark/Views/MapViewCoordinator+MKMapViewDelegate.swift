// Views/MapViewCoordinator+MKMapViewDelegate.swift

import MapKit
import SwiftUI

extension MapViewCoordinator: MKMapViewDelegate {
    // Renderer for overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let roadOverlay = overlay as? RoadOverlay {
            let renderer = MKPolylineRenderer(polyline: roadOverlay)

            if let road = roadOverlay.road {
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
                renderer.strokeColor = UIColor.gray.withAlphaComponent(0.7)
            }

            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }

    // View for annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Handle user location annotation
        if let userLocation = annotation as? MKUserLocation {
            let identifier = "UserLocation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: userLocation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = userLocation
            }

            // Customize the user location annotation view
            let outerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            outerView.backgroundColor = UIColor(Color.customBackground)
            outerView.layer.cornerRadius = 10

            let innerView = UIView(frame: CGRect(x: 5, y: 5, width: 10, height: 10))
            innerView.backgroundColor = UIColor.white
            innerView.layer.cornerRadius = 5

            outerView.addSubview(innerView)

            UIGraphicsBeginImageContextWithOptions(outerView.bounds.size, false, UIScreen.main.scale)
            outerView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            annotationView?.image = image

            return annotationView
        }

        // Handle RoadAnnotations
        if let roadAnnotation = annotation as? RoadAnnotation {
            let identifier = "RoadAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: roadAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = roadAnnotation
            }

            // Make the annotation view invisible but with a larger touch area
            annotationView?.isEnabled = true
            annotationView?.alpha = 0.001
            annotationView?.frame.size = CGSize(width: 44, height: 44) // Increase touch area
            annotationView?.centerOffset = CGPoint(x: 0, y: 0)

            return annotationView
        }

        // Handle the custom annotation for long-press
        if let pointAnnotation = annotation as? MKPointAnnotation {
            let identifier = "CustomAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: pointAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                // Customize the marker
                annotationView?.markerTintColor = UIColor(Color.customBackground)
                annotationView?.glyphImage = UIImage(systemName: "mappin")
                annotationView?.glyphTintColor = UIColor.white

                // Add a button to the callout
                let directionsButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = directionsButton
            } else {
                annotationView?.annotation = pointAnnotation
            }

            return annotationView
        }

        return nil
    }

    // Handle tap on callout accessory view
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let coordinate = view.annotation?.coordinate {
            // Open in Apple Maps
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = view.annotation?.title ?? "Destination"

            // Provide options to the user
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }

    // Handle road annotation selection
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
