// LoadGeoJSON.swift

import Foundation
import MapKit

class GeoJSONLoader {
    static func loadGeoJSON(named fileName: String) -> [MKOverlay] {
        var overlays = [MKOverlay]()
        if let url = Bundle.main.url(forResource: fileName, withExtension: "geojson") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = MKGeoJSONDecoder()
                let features = try decoder.decode(data)
                for feature in features {
                    if let mkFeature = feature as? MKGeoJSONFeature {
                        for geometry in mkFeature.geometry {
                            if let polyline = geometry as? MKPolyline {
                                overlays.append(polyline)
                            } else if let polygon = geometry as? MKPolygon {
                                overlays.append(polygon)
                            }
                        }
                    }
                }
            } catch {
                print("Error loading GeoJSON: \(error)")
            }
        } else {
            print("Could not find \(fileName).geojson")
        }
        return overlays
    }
}
