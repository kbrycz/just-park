// Views/MapViewCoordinator+Gesture.swift

import MapKit

extension MapViewCoordinator {
    // Handle long-press gesture
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // Only handle the gesture when it begins
        if gestureRecognizer.state == .began {
            let locationInView = gestureRecognizer.location(in: gestureRecognizer.view)
            if let mapView = gestureRecognizer.view as? MKMapView {
                let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)

                // Remove existing temporary annotation if any
                if let existingAnnotation = selectedAnnotation {
                    mapView.removeAnnotation(existingAnnotation)
                }

                // Create a new annotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "Selected Location"
                annotation.subtitle = "Loading address..."

                mapView.addAnnotation(annotation)
                selectedAnnotation = annotation

                // Reverse-geocode to get address
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        print("Reverse geocode failed: \(error.localizedDescription)")
                        return
                    }

                    if let placemark = placemarks?.first {
                        let address = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.postalCode]
                            .compactMap { $0 }
                            .joined(separator: ", ")

                        DispatchQueue.main.async {
                            annotation.subtitle = address
                            mapView.selectAnnotation(annotation, animated: true)
                        }
                    }
                }
            }
        }
    }
}
