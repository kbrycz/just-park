// Extensions/MKCoordinateRegion+Extensions.swift

import MapKit

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
