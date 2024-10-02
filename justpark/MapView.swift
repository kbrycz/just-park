import SwiftUI
import MapKit
import ObjectiveC.runtime

struct MapView: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var overlays: [MKOverlay]
    @Binding var annotations: [MKAnnotation]
    var roads: [Road]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.setRegion(locationManager.region, animated: true) // Set region here

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Do not reset the region here

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

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)

                // Retrieve the associated Road object
                if let road = objc_getAssociatedObject(polyline, &roadAssociatedKey) as? Road {
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
                    print("No associated road found for polyline")
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
    }
}