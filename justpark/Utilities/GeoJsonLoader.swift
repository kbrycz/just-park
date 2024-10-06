// Utilities/GeoJSONLoader.swift

import Foundation
import MapKit

struct GeoJSONLoader {
    static func loadGeoJSONData(fileName: String) -> (overlays: [MKOverlay], annotations: [MKAnnotation], roads: [Road]) {
        var overlays: [MKOverlay] = []
        var annotations: [MKAnnotation] = []
        var roads: [Road] = []

        if let url = Bundle.main.url(forResource: fileName, withExtension: "geojson") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = MKGeoJSONDecoder()
                let features = try decoder.decode(data) as? [MKGeoJSONFeature]

                for feature in features ?? [] {
                    if let lineString = feature.geometry.first as? MKPolyline,
                       let propertiesData = feature.properties,
                       let properties = try JSONSerialization.jsonObject(with: propertiesData) as? [String: Any],
                       let id = properties["id"] as? Int,
                       let name = properties["name"] as? String,
                       let cleaningDatesStrings = properties["cleaning_dates"] as? [String] {

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let cleaningDates = cleaningDatesStrings.compactMap { dateFormatter.date(from: $0) }

                        // Randomly assign a status
                        let statuses = ["red", "yellow", "green"]
                        let randomStatus = statuses.randomElement() ?? "green"

                        let road = Road(id: id, name: name, cleaningDates: cleaningDates, status: randomStatus)
                        roads.append(road)

                        // Create RoadOverlay
                        let pointCount = lineString.pointCount
                        var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
                        lineString.getCoordinates(&coordinates, range: NSRange(location: 0, length: pointCount))

                        let polyline = RoadOverlay(coordinates: coordinates, count: pointCount)
                        polyline.road = road

                        overlays.append(polyline)

                        // Place annotations along the polyline
                        for (index, coordinate) in coordinates.enumerated() {
                            if index % 2 == 0 {
                                let annotation = RoadAnnotation(coordinate: coordinate)
                                annotation.road = road
                                annotations.append(annotation)
                            }
                        }
                    }
                }

            } catch {
                print("Error loading GeoJSON data: \(error)")
            }
        } else {
            print("Could not find \(fileName).geojson")
        }

        return (overlays, annotations, roads)
    }
}
