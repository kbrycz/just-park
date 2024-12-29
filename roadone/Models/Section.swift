// Section.swift

import Foundation
import MapKit

class Section: Identifiable, ObservableObject {
    let id = UUID()
    let ward: Int
    let sectionNumber: Int
    let hood: String
    @Published var cleaningDates: [Date] = []
    var overlays: [MKOverlay] = []

    init(ward: Int, sectionNumber: Int, hood: String) {
        self.ward = ward
        self.sectionNumber = sectionNumber
        self.hood = hood
    }

    func nextCleaningDates() -> [Date] {
        let today = Date()
        let calendar = Calendar.current

        // 1. Filter to keep only those that are either in the future
        //    or up to one week in the past
        let relevant = cleaningDates.filter { date in
            if date >= today {
                return true
            } else {
                // If in the past, keep if within last 7 days
                if let diff = calendar.dateComponents([.day], from: date, to: today).day,
                   diff <= 7 {
                    return true
                }
                return false
            }
        }

        // 2. Sort ascending
        let sorted = relevant.sorted()

        // 3. Grab next 2
        //    If they've all passed more than a week, it might be empty, but that's correct logic
        let nextTwo = Array(sorted.prefix(2))
        return nextTwo
    }
}
