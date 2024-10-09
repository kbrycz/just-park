// Utilities/CleaningDatesFetcher.swift

import Foundation

struct CleaningDatesFetcher {
    static func fetchCleaningDates(ward: Int, section: Int, completion: @escaping ([Date]?) -> Void) {
        let urlString = "http://localhost:3000/cleaning-dates?ward=\(ward)&section=\(section)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
    
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching cleaning dates: \(error)")
                completion(nil)
                return
            }
    
            guard let data = data else {
                completion(nil)
                return
            }
    
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let datesStrings = json["cleaning_dates"] as? [String] {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dates = datesStrings.compactMap { dateFormatter.date(from: $0) }
                    completion(dates)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error parsing cleaning dates JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
