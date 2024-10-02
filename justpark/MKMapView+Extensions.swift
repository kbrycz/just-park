// MKMapView+Extensions.swift

import MapKit

extension MKMapView {
    func deselectOverlay(_ overlay: MKOverlay) {
        if let renderer = self.renderer(for: overlay) as? MKOverlayPathRenderer {
            renderer.setNeedsDisplay()
        }
    }
}
