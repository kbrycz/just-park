// Section.swift

import Foundation
import MapKit

class Section: Identifiable, ObservableObject {
    let id = UUID()
    let ward: Int
    let sectionNumber: Int
    let hood: String
    @Published var cleaningDates: [Date] = []
    var overlays: [MKOverlay] = [] // Store all overlays (polygons and polylines) for this section

    init(ward: Int, sectionNumber: Int, hood: String) {
        self.ward = ward
        self.sectionNumber = sectionNumber
        self.hood = hood
    }

    func nextCleaningDates() -> [Date] {
        let today = Date()
        let calendar = Calendar.current

        let relevantDates = cleaningDates.filter {
            $0 >= today || (calendar.dateComponents([.day], from: $0, to: today).day ?? 0) <= 7
        }.sorted()

        return Array(relevantDates.prefix(2))
    }

    func daysUntilNextCleaning() -> Int? {
        let today = Date()
        if let nextDate = nextCleaningDates().first {
            let calendar = Calendar.current
            if let days = calendar.dateComponents([.day], from: today, to: nextDate).day {
                return days
            }
        }
        return nil
    }
}
