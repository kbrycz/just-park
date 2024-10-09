// Utilities/GeoJSONLoader.swift

import Foundation
import MapKit

struct GeoJSONLoader {
    static func loadGeoJSONData(fileName: String, inSubdirectory subdirectory: String? = nil) -> (overlays: [MKOverlay], annotations: [MKAnnotation], roads: [Road]) {
        var overlays: [MKOverlay] = []
        var annotations: [MKAnnotation] = []
        var roads: [Road] = []

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
            return (overlays, annotations, roads)
        }
        do {
            let data = try Data(contentsOf: geoJSONURL)
            // Parse the entire GeoJSON to extract ward and section
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ward = json["ward"] as? Int,
               let section = json["section"] as? Int,
               let featuresArray = json["features"] as? [[String: Any]] {

                print("Found \(featuresArray.count) features in GeoJSON.")

                for (index, featureDict) in featuresArray.enumerated() {
                    if let geometry = featureDict["geometry"] as? [String: Any],
                       let geometryType = geometry["type"] as? String,
                       geometryType == "LineString",
                       let coordinatesArray = geometry["coordinates"] as? [[Double]],
                       let properties = featureDict["properties"] as? [String: Any],
                       let id = properties["id"] as? Int,
                       let name = properties["name"] as? String {

                        // Convert coordinates to CLLocationCoordinate2D
                        let coordinates = coordinatesArray.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }

                        // Randomly assign a status
                        let statuses = ["red", "yellow", "green"]
                        let randomStatus = statuses.randomElement() ?? "green"

                        let road = Road(id: id, name: name, ward: ward, section: section, status: randomStatus)
                        roads.append(road)

                        // Create RoadOverlay
                        let polyline = RoadOverlay(coordinates: coordinates, count: coordinates.count)
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
                    } else {
                        print("Feature at index \(index) is missing required properties.")
                    }
                }
                print("Loaded \(roads.count) roads from \(fileName).geojson")
            } else {
                print("Error parsing GeoJSON data: Missing ward or section.")
            }
        } catch {
            print("Error loading GeoJSON data: \(error)")
        }

        return (overlays, annotations, roads)
    }
}
