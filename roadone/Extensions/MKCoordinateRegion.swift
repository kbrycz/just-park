// Extensions/MKCoordinateRegion+Extensions.swift

import MapKit

extension MKCoordinateRegion {
    func isEqual(to region: MKCoordinateRegion) -> Bool {
        let centerEqual = self.center.latitude == region.center.latitude &&
                          self.center.longitude == region.center.longitude
        let spanEqual = self.span.latitudeDelta == region.span.latitudeDelta &&
                        self.span.longitudeDelta == region.span.longitudeDelta
        return centerEqual && spanEqual
    }
}
