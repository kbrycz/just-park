// GeoJSONLoader.swift

import Foundation
import MapKit

struct GeoJSONLoader {
    static func loadAllSections() -> (overlays: [MKOverlay], annotations: [MKAnnotation], sections: [Section]) {
        var overlays: [MKOverlay] = []
        var annotations: [MKAnnotation] = []
        var sections: [Section] = []

        // Assuming all your ward folders are in the main bundle's resource path
        // Read ward toggles from UserDefaults
        // If the key does not exist, default to true (i.e., load the ward by default).
        func isWardEnabled(_ wardKey: String) -> Bool {
            return UserDefaults.standard.object(forKey: wardKey) as? Bool ?? true
        }

        let allPossibleWards = ["ward_44", "ward_43", "ward_46", "ward_48", "ward_47", "ward_42", "ward_2", "ward_27", "ward_32"]
        let enabledWards = allPossibleWards.filter { wardName in
            // Convert something like "ward_43" to "ward_43_enabled" to check
            let prefKey = "\(wardName)_enabled"
            return isWardEnabled(prefKey)
        }

        let wards = enabledWards

        
        for ward in wards {
            // Get all GeoJSON files in the ward directory
            if let wardURL = Bundle.main.resourceURL?.appendingPathComponent(ward) {
                do {
                    let fileURLs = try FileManager.default.contentsOfDirectory(at: wardURL, includingPropertiesForKeys: nil)
                    for fileURL in fileURLs where fileURL.pathExtension == "geojson" {
                        let fileName = fileURL.deletingPathExtension().lastPathComponent
                        let result = loadSectionGeoJSONData(fileName: fileName, inSubdirectory: ward)
                        overlays.append(contentsOf: result.overlays)
                        annotations.append(contentsOf: result.annotations)
                        if let section = result.section {
                            sections.append(section)
                        }
                    }
                } catch {
                    print("Error reading contents of ward directory: \(error)")
                }
            }
        }

        return (overlays, annotations, sections)
    }

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

                print("Found \(featuresArray.count) features in \(fileName).geojson.")

                // Create the Section with hood
                let newSection = Section(ward: ward, sectionNumber: sectionNumber, hood: hood)

                var sectionOverlays: [MKOverlay] = []

                for (index, featureDict) in featuresArray.enumerated() {
                    if let geometry = featureDict["geometry"] as? [String: Any],
                       let geometryType = geometry["type"] as? String {

                        if geometryType == "Polygon",
                           let coordinatesArray = geometry["coordinates"] as? [[[Double]]] {

                            // The first coordinateSet is the outer ring
                            let exteriorCoordsSet = coordinatesArray.first
                            let interiorCoordsSets = coordinatesArray.dropFirst()

                            if let exteriorCoordsSet = exteriorCoordsSet {
                                // Reverse the coordinates to ensure counter-clockwise order
                                let exteriorCoords = Array(exteriorCoordsSet.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }.reversed())

                                var interiorPolygons: [MKPolygon] = []

                                for interiorCoordsSet in interiorCoordsSets {
                                    // Reverse the coordinates to ensure clockwise order for holes
                                    let interiorCoords = interiorCoordsSet.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
                                    let interiorPolygon = MKPolygon(coordinates: interiorCoords, count: interiorCoords.count)
                                    interiorPolygons.append(interiorPolygon)
                                }

                                let polygon = SectionPolygon(coordinates: exteriorCoords, count: exteriorCoords.count, interiorPolygons: interiorPolygons)
                                polygon.section = newSection
                                sectionOverlays.append(polygon)
                            }
                        } else if geometryType == "MultiPolygon",
                                  let coordinatesArray = geometry["coordinates"] as? [[[[Double]]]] {

                            // Handle MultiPolygon
                            for polygonCoordsArray in coordinatesArray {
                                // Each polygonCoordsArray represents a polygon (with possible interior rings)
                                let exteriorCoordsSet = polygonCoordsArray.first
                                let interiorCoordsSets = polygonCoordsArray.dropFirst()

                                if let exteriorCoordsSet = exteriorCoordsSet {
                                    // Reverse the coordinates to ensure counter-clockwise order
                                    let exteriorCoords = Array(exteriorCoordsSet.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }.reversed())

                                    var interiorPolygons: [MKPolygon] = []

                                    for interiorCoordsSet in interiorCoordsSets {
                                        // Reverse the coordinates to ensure clockwise order for holes
                                        let interiorCoords = interiorCoordsSet.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
                                        let interiorPolygon = MKPolygon(coordinates: interiorCoords, count: interiorCoords.count)
                                        interiorPolygons.append(interiorPolygon)
                                    }

                                    let polygon = SectionPolygon(coordinates: exteriorCoords, count: exteriorCoords.count, interiorPolygons: interiorPolygons)
                                    polygon.section = newSection
                                    sectionOverlays.append(polygon)
                                }
                            }
                        } else if geometryType == "LineString",
                                  let coordinatesArray = geometry["coordinates"] as? [[Double]] {
                            let coordinates = coordinatesArray.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
                            // Check if LineString is a closed loop (first coordinate == last coordinate)
                            if coordinates.first == coordinates.last && coordinates.count >= 4 {
                                // Reverse the coordinates to ensure counter-clockwise order
                                let reversedCoords = Array(coordinates.reversed())
                                // It's a closed loop, create a polygon
                                let polygon = SectionPolygon(coordinates: reversedCoords, count: reversedCoords.count)
                                polygon.section = newSection
                                sectionOverlays.append(polygon)
                            } else {
                                // Not a closed loop, create a polyline
                                let polyline = SectionPolyline(coordinates: coordinates, count: coordinates.count)
                                polyline.section = newSection
                                sectionOverlays.append(polyline)
                            }
                        } else {
                            print("Unsupported geometry type: \(geometryType)")
                        }
                    } else {
                        print("Feature at index \(index) is missing required properties.")
                    }
                }

                if !sectionOverlays.isEmpty {
                    // Add overlays to the section
                    overlays.append(contentsOf: sectionOverlays)
                    newSection.overlays = sectionOverlays // Store all overlays for this section
                    section = newSection
                }

            } else {
                print("Error parsing GeoJSON data: Missing ward, section, or hood.")
            }
        } catch {
            print("Error loading GeoJSON data: \(error)")
        }

        return (overlays, annotations, section)
    }
}
