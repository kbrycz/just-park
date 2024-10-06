// Models/Road.swift

import Foundation
import MapKit

struct Road: Identifiable {
    let id: Int
    let name: String
    let cleaningDates: [Date]
    let status: String // Add this line to include the status property
}

class RoadOverlay: MKPolyline {
    var road: Road?
}

extension Road {
    func nextCleaningDate() -> Date? {
        let today = Date()
        let futureDates = cleaningDates.filter { $0 >= today }
        return futureDates.sorted().first
    }

    func getStatus() -> String {
        // Since status is now a property, simply return it
        return status
    }
}
