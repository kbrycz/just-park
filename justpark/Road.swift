// Road.swift

import Foundation
import MapKit

struct Road: Identifiable {
    let id: Int
    let name: String
    let cleaningDates: [Date]
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
