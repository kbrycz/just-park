import Foundation

struct LocalCleaningDatesLoader {
    
    struct WardDates: Decodable {
        let ward: Int
        let sections: [SectionDates]
    }
    
    struct SectionDates: Decodable {
        let section: Int
        let dates: [String]
    }
    
    // We'll decode a top-level JSON like { "wards": [ { ward:..., sections:...}, ... ] }
    struct DatesFile: Decodable {
        let wards: [WardDates]
    }
    
    // Cache the parsed data in memory so we don't parse multiple times
    private static var cachedData: DatesFile?

    static func loadAllDates() -> DatesFile? {
        // If we already parsed it, return
        if let data = cachedData {
            return data
        }
        
        // Attempt to load from bundle
        guard let url = Bundle.main.url(forResource: "dates", withExtension: "json") else {
            print("❌ Could not find dates.json in bundle.")
            return nil
        }
        
        do {
            let rawData = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DatesFile.self, from: rawData)
            cachedData = decoded // Cache result
            return decoded
        } catch {
            print("❌ Error parsing dates.json: \(error)")
            return nil
        }
    }
    
    /// Get a sorted list of `Date` for a given ward/section, or `nil` if not found.
    static func getDates(forWard ward: Int, section: Int) -> [Date]? {
        guard let allData = loadAllDates() else { return nil }
        
        // Find the matching ward
        guard let wardObj = allData.wards.first(where: { $0.ward == ward }) else {
            return nil
        }
        // Find the matching section
        guard let sectionObj = wardObj.sections.first(where: { $0.section == section }) else {
            return nil
        }
        // Convert string to Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let parsedDates = sectionObj.dates.compactMap { dateFormatter.date(from: $0) }
        // Sort them ascending
        return parsedDates.sorted()
    }
}
