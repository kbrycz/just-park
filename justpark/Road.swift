// Road.swift

import Foundation
import MapKit

struct Road: Identifiable {
    let id: Int
    let name: String
    let cleaningDates: [Date]
    let polyline: MKPolyline

    func nextCleaningDate() -> Date? {
        let today = Date()
        let futureDates = cleaningDates.filter { $0 >= today }
        return futureDates.sorted().first
    }

    func status() -> String {
        guard let nextDate = nextCleaningDate() else {
            return "clear"
        }
        let calendar = Calendar.current
        let daysUntilCleaning = calendar.dateComponents([.day], from: Date(), to: nextDate).day ?? Int.max

        if daysUntilCleaning <= 2 {
            return "red"
        } else if daysUntilCleaning <= 7 {
            return "yellow"
        } else {
            return "clear"
        }
    }
}

// Extension to calculate midpoint of coordinates array
extension Array where Element == CLLocationCoordinate2D {
    var midpoint: CLLocationCoordinate2D? {
        guard !self.isEmpty else { return nil }
        let total = self.reduce((latitude: 0.0, longitude: 0.0)) { (result, coord) -> (latitude: Double, longitude: Double) in
            (latitude: result.latitude + coord.latitude, longitude: result.longitude + coord.longitude)
        }
        let count = Double(self.count)
        return CLLocationCoordinate2D(latitude: total.latitude / count, longitude: total.longitude / count)
    }
}
