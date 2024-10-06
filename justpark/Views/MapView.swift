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

        // Show user's location
        mapView.showsUserLocation = true

        // Set the map's initial region
        mapView.setRegion(locationManager.region, animated: true)

        // Exclude all points of interest
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll

        // Add long-press gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecognizer)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update the region only if it has changed
        if !mapView.region.isEqual(to: locationManager.region) {
            mapView.setRegion(locationManager.region, animated: true)
        }

        // Remove existing overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        // Add new overlays and annotations
        mapView.addOverlays(overlays)
        mapView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, locationManager: locationManager)
    }

    typealias Coordinator = MapViewCoordinator
}
