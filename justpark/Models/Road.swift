// Models/Road.swift

import Foundation
import MapKit

class Road: Identifiable {
    let id: Int
    let name: String
    let ward: Int
    let section: Int
    var cleaningDates: [Date] = []
    let status: String

    init(id: Int, name: String, ward: Int, section: Int, status: String) {
        self.id = id
        self.name = name
        self.ward = ward
        self.section = section
        self.status = status
    }
}

class RoadOverlay: MKPolyline {
    var road: Road?
}

extension Road {
    func nextCleaningDates() -> [Date] {
        let today = Date()
        let calendar = Calendar.current

        // Filter future dates or dates within the past week
        let relevantDates = cleaningDates.filter {
            $0 >= today || calendar.dateComponents([.day], from: $0, to: today).day! <= 7
        }.sorted()

        // If the current month's dates have passed by at least one week, move to next month
        if let firstDate = relevantDates.first, firstDate < today {
            let daysSinceDate = calendar.dateComponents([.day], from: firstDate, to: today).day!
            if daysSinceDate > 7 {
                // Move to dates after this month
                let nextMonthDates = relevantDates.filter {
                    calendar.component(.month, from: $0) != calendar.component(.month, from: today)
                }
                return Array(nextMonthDates.prefix(2))
            }
        }

        // Return the next two relevant dates
        return Array(relevantDates.prefix(2))
    }

    func getStatus() -> String {
        return status
    }
}
