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

        // Update overlays if they have changed
        updateOverlays(on: mapView)

        // Update annotations if they have changed
        updateAnnotations(on: mapView)
    }

    private func updateOverlays(on mapView: MKMapView) {
        // Compare the current overlays with the new ones
        let currentOverlays = mapView.overlays
        if !areOverlaysEqual(currentOverlays, overlays) {
            // Remove existing overlays
            mapView.removeOverlays(currentOverlays)
            // Add new overlays
            mapView.addOverlays(overlays)
            print("Overlays updated on map.")
        }
    }

    private func updateAnnotations(on mapView: MKMapView) {
        // Compare the current annotations with the new ones
        let currentAnnotations = mapView.annotations
        if !areAnnotationsEqual(currentAnnotations, annotations) {
            // Remove existing annotations
            mapView.removeAnnotations(currentAnnotations)
            // Add new annotations
            mapView.addAnnotations(annotations)
            print("Annotations updated on map.")
        }
    }

    private func areOverlaysEqual(_ overlays1: [MKOverlay], _ overlays2: [MKOverlay]) -> Bool {
        guard overlays1.count == overlays2.count else { return false }
        for (overlay1, overlay2) in zip(overlays1, overlays2) {
            if overlay1 !== overlay2 {
                return false
            }
        }
        return true
    }

    private func areAnnotationsEqual(_ annotations1: [MKAnnotation], _ annotations2: [MKAnnotation]) -> Bool {
        guard annotations1.count == annotations2.count else { return false }
        for (annotation1, annotation2) in zip(annotations1, annotations2) {
            if annotation1 !== annotation2 {
                return false
            }
        }
        return true
    }

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
}
