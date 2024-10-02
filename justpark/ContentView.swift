// ContentView.swift

import SwiftUI
import MapKit
import ObjectiveC.runtime

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var overlays: [MKOverlay] = []
    @State private var roads: [Road] = []
    @State private var annotations: [MKAnnotation] = []
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            MapView(overlays: $overlays, annotations: $annotations, roads: roads)
                .environmentObject(locationManager)
                .edgesIgnoringSafeArea(.all)
            ZoomControls()
                .environmentObject(locationManager)
                .padding(.top, 50)
                .padding(.trailing, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .onAppear {
            loadGeoJSONData()
        }
        .onReceive(locationManager.$selectedRoad) { road in
            if let road = road {
                if let nextDate = road.nextCleaningDate() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .full // Include day of the week
                    let dateString = dateFormatter.string(from: nextDate)
                    alertTitle = road.name
                    alertMessage = "Next street cleaning on \(dateString)"
                } else {
                    alertTitle = road.name
                    alertMessage = "\(road.name) has no upcoming street cleaning dates."
                }
                showingAlert = true
                locationManager.selectedRoad = nil
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func loadGeoJSONData() {
            if let url = Bundle.main.url(forResource: "LakeViewStreets", withExtension: "geojson") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = MKGeoJSONDecoder()
                    let features = try decoder.decode(data) as? [MKGeoJSONFeature]

                    var loadedRoads: [Road] = []
                    var loadedAnnotations: [MKAnnotation] = []

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

                            // Create RoadPolyline
                            let pointCount = lineString.pointCount
                            var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
                            lineString.getCoordinates(&coordinates, range: NSRange(location: 0, length: pointCount))

                            let polyline = RoadPolyline(coordinates: coordinates, count: pointCount)
                            polyline.roadID = id

                            let road = Road(id: id, name: name, cleaningDates: cleaningDates, polyline: polyline)
                            loadedRoads.append(road)

                            overlays.append(polyline)

                            // Place annotations along the polyline
                            for (index, coordinate) in coordinates.enumerated() {
                                if index % 2 == 0 {
                                    let annotation = RoadAnnotation(coordinate: coordinate)
                                    annotation.road = road
                                    loadedAnnotations.append(annotation)
                                }
                            }
                        }
                    }

                    roads = loadedRoads
                    annotations = loadedAnnotations

                } catch {
                    print("Error loading GeoJSON data: \(error)")
                }
            } else {
                print("Could not find LakeViewStreets.geojson")
            }
        }
}
