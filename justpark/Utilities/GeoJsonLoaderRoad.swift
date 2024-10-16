// GeoJSONLoaderRoad.swift

import Foundation
import MapKit

struct GeoJSONLoaderRoad {

    // The loadRoadGeoJSONData function remains unchanged
    static func loadRoadGeoJSONData(fileName: String, inSubdirectory subdirectory: String? = nil) -> (overlays: [MKOverlay], annotations: [MKAnnotation]) {
            var overlays: [MKOverlay] = []
            var annotations: [MKAnnotation] = []

            let bundle = Bundle.main
            let url: URL?

            if let subdirectory = subdirectory {
                url = bundle.url(forResource: fileName, withExtension: "geojson", subdirectory: subdirectory)
            } else {
                url = bundle.url(forResource: fileName, withExtension: "geojson")
            }

            guard let geoJSONURL = url else {
                if let subdirectory = subdirectory {
                    print("Could not find \(subdirectory)/\(fileName).geojson")
                } else {
                    print("Could not find \(fileName).geojson")
                }
                return (overlays, annotations)
            }

            do {
                let data = try Data(contentsOf: geoJSONURL)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let featuresArray = json["features"] as? [[String: Any]] {

                    print("Found \(featuresArray.count) road features in GeoJSON.")

                    for (index, featureDict) in featuresArray.enumerated() {
                        if let properties = featureDict["properties"] as? [String: Any],
                           let id = properties["id"] as? Int,
                           let name = properties["name"] as? String,
                           let ward = properties["ward"] as? Int,
                           let section = properties["section"] as? Int,
                           let status = properties["status"] as? String,
                           let geometry = featureDict["geometry"] as? [String: Any],
                           let geometryType = geometry["type"] as? String,
                           geometryType == "LineString",
                           let coordinatesArray = geometry["coordinates"] as? [[Double]] {

                            // Convert coordinates to CLLocationCoordinate2D
                            let lineCoordinates = coordinatesArray.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }

                            // Create the Road object
                            let road = Road(id: id, name: name)

                            // Create the RoadOverlay
                            let polyline = RoadOverlay(coordinates: lineCoordinates, count: lineCoordinates.count)
                            polyline.road = road

                            // Add to overlays
                            overlays.append(polyline)
                        } else {
                            print("Road feature at index \(index) is missing required properties.")
                        }
                    }
                } else {
                    print("Error parsing road GeoJSON data.")
                }
            } catch {
                print("Error loading road GeoJSON data: \(error)")
            }

            return (overlays, annotations)
        }
}
