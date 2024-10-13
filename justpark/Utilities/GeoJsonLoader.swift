// Utilities/GeoJSONLoader.swift

import Foundation
import MapKit

struct GeoJSONLoader {
    static func loadSectionGeoJSONData(fileName: String, inSubdirectory subdirectory: String? = nil) -> (overlays: [MKOverlay], annotations: [MKAnnotation], section: Section?) {
        var overlays: [MKOverlay] = []
        var annotations: [MKAnnotation] = []
        var section: Section?

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
            return (overlays, annotations, section)
        }

        do {
            let data = try Data(contentsOf: geoJSONURL)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ward = json["ward"] as? Int,
               let sectionNumber = json["section"] as? Int,
               let hood = json["hood"] as? String,
               let featuresArray = json["features"] as? [[String: Any]] {

                print("Found \(featuresArray.count) features in GeoJSON.")

                var coordinates: [CLLocationCoordinate2D] = []

                for (index, featureDict) in featuresArray.enumerated() {
                    if let geometry = featureDict["geometry"] as? [String: Any],
                       let geometryType = geometry["type"] as? String,
                       geometryType == "LineString",
                       let coordinatesArray = geometry["coordinates"] as? [[Double]] {

                        // Convert coordinates to CLLocationCoordinate2D and append
                        let lineCoordinates = coordinatesArray.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
                        coordinates.append(contentsOf: lineCoordinates)
                    } else {
                        print("Feature at index \(index) is missing required properties.")
                    }
                }

                if !coordinates.isEmpty {
                    // Close the polygon by adding the first coordinate at the end if necessary
                    if coordinates.first != coordinates.last {
                        coordinates.append(coordinates.first!)
                    }

                    // Create the polygon
                    let polygon = SectionOverlay(coordinates: coordinates, count: coordinates.count)
                    // Create the Section with hood
                    let newSection = Section(ward: ward, sectionNumber: sectionNumber, hood: hood)
                    newSection.polygon = polygon
                    polygon.section = newSection // Set the section reference
                    section = newSection
                    polygon.title = "SectionOverlay"

                    overlays.append(polygon)
                }

            } else {
                print("Error parsing GeoJSON data: Missing ward, section, or hood.")
            }
        } catch {
            print("Error loading GeoJSON data: \(error)")
        }

        return (overlays, annotations, section)
    }
    
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
