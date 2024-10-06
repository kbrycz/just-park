// Views/MapView.swift

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var overlays: [MKOverlay]
    @Binding var annotations: [MKAnnotation]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator

        // Do not show the user's location
        mapView.showsUserLocation = false

        // Set the map's initial region
        mapView.setRegion(locationManager.region, animated: true)

        // Exclude all points of interest
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update the region only if it has changed significantly
        if !mapView.region.isApproximatelyEqual(to: locationManager.region) {
            mapView.setRegion(locationManager.region, animated: false)
        }

        // Remove existing overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        // Add new overlays and annotations
        mapView.addOverlays(overlays)
        mapView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

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
}

// Add this extension to compare regions approximately
extension MKCoordinateRegion {
    func isApproximatelyEqual(to region: MKCoordinateRegion) -> Bool {
        let epsilon = 0.0001
        let centerEqual = abs(self.center.latitude - region.center.latitude) < epsilon &&
                          abs(self.center.longitude - region.center.longitude) < epsilon
        let spanEqual = abs(self.span.latitudeDelta - region.span.latitudeDelta) < epsilon &&
                        abs(self.span.longitudeDelta - region.span.longitudeDelta) < epsilon
        return centerEqual && spanEqual
    }
}
