// MapView.swift

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var overlays: [MKOverlay]
    var roads: [Road]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.setRegion(locationManager.region, animated: true)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(locationManager.region, animated: true)

        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)

        // Add new overlays
        mapView.addOverlays(overlays)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, roads: roads)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var roads: [Road]

        init(_ parent: MapView, roads: [Road]) {
            self.parent = parent
            self.roads = roads
        }

        // Use the custom renderer
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = SelectablePolylineRenderer(polyline: polyline)

                if let road = roads.first(where: { $0.polyline === polyline }) {
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
                renderer.isOpaque = false
                return renderer
            }
            return MKOverlayRenderer()
        }

        // Handle tap on overlay
        func mapView(_ mapView: MKMapView, didSelect overlay: MKOverlay) {
            if let polyline = overlay as? MKPolyline,
               let road = roads.first(where: { $0.polyline === polyline }) {
                DispatchQueue.main.async {
                    self.parent.locationManager.selectedRoad = road
                }
            }
            // Deselect overlay to allow re-selection
            mapView.deselectOverlay(overlay)
        }

        // Enable selection on overlays
        func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
            for renderer in renderers {
                if let polylineRenderer = renderer as? SelectablePolylineRenderer {
                    polylineRenderer.alpha = polylineRenderer.strokeColor.cgColor.alpha
                }
            }
        }
    }
}
