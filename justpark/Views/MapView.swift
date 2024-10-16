// MapView.swift

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var overlays: [MKOverlay]
    @Binding var annotations: [MKAnnotation]
    @Binding var sections: [Section]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator

        // Do not show the user's location
        mapView.showsUserLocation = false

        // Exclude all points of interest
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        // Set initial region
        mapView.setRegion(locationManager.region, animated: false)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update overlays if they have changed
        updateOverlays(on: mapView, context: context)

        // Update annotations if they have changed
        updateAnnotations(on: mapView)

        // Update map region if it has changed
        if mapView.region.center.latitude != locationManager.region.center.latitude ||
            mapView.region.center.longitude != locationManager.region.center.longitude ||
            mapView.region.span.latitudeDelta != locationManager.region.span.latitudeDelta ||
            mapView.region.span.longitudeDelta != locationManager.region.span.longitudeDelta {

            mapView.setRegion(locationManager.region, animated: true)
        }
    }

    private func updateOverlays(on mapView: MKMapView, context: Context) {
        let currentOverlays = mapView.overlays
        if !areOverlaysEqual(currentOverlays, overlays) {
            mapView.removeOverlays(currentOverlays)
            mapView.addOverlays(overlays)
            print("Overlays updated on map.")

            // Adjust the map region only once or when overlays change
            if !context.coordinator.didSetInitialRegion, !overlays.isEmpty {
                let mapRect = overlays.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
                mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20), animated: true)
                context.coordinator.didSetInitialRegion = true
            }
        }
    }

    private func updateAnnotations(on mapView: MKMapView) {
        let currentAnnotations = mapView.annotations
        if !areAnnotationsEqual(currentAnnotations, annotations) {
            mapView.removeAnnotations(currentAnnotations)
            mapView.addAnnotations(annotations)
            print("Annotations updated on map.")
        }
    }

    private func areOverlaysEqual(_ overlays1: [MKOverlay], _ overlays2: [MKOverlay]) -> Bool {
        return overlays1.count == overlays2.count
    }

    private func areAnnotationsEqual(_ annotations1: [MKAnnotation], _ annotations2: [MKAnnotation]) -> Bool {
        return annotations1.count == annotations2.count
    }

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
