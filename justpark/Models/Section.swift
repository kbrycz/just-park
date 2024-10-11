// Models/Section.swift

import Foundation
import MapKit

class Section: Identifiable, ObservableObject {
    let id = UUID()
    let ward: Int
    let sectionNumber: Int
    let hood: String  // Added hood property
    @Published var cleaningDates: [Date] = []
    var polygon: MKPolygon?

    init(ward: Int, sectionNumber: Int, hood: String) {
        self.ward = ward
        self.sectionNumber = sectionNumber
        self.hood = hood  // Initialize hood
    }

    func nextCleaningDates() -> [Date] {
        let today = Date()
        let calendar = Calendar.current

        let relevantDates = cleaningDates.filter {
            $0 >= today || (calendar.dateComponents([.day], from: $0, to: today).day ?? 0) <= 7
        }.sorted()

        return Array(relevantDates.prefix(2))
    }
}
