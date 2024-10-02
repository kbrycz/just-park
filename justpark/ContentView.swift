// ContentView.swift

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var overlays: [MKOverlay] = []
    @State private var roads: [Road] = []
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            MapView(overlays: $overlays, roads: roads)
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

                for feature in features ?? [] {
                    if let polyline = feature.geometry.first as? MKPolyline,
                       let propertiesData = feature.properties,
                       let properties = try JSONSerialization.jsonObject(with: propertiesData) as? [String: Any],
                       let id = properties["id"] as? Int,
                       let name = properties["name"] as? String,
                       let cleaningDatesStrings = properties["cleaning_dates"] as? [String] {

                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let cleaningDates = cleaningDatesStrings.compactMap { dateFormatter.date(from: $0) }

                        let road = Road(id: id, name: name, cleaningDates: cleaningDates, polyline: polyline)
                        loadedRoads.append(road)

                        overlays.append(polyline)
                    }
                }

                roads = loadedRoads

            } catch {
                print("Error loading GeoJSON data: \(error)")
            }
        } else {
            print("Could not find LakeViewStreets.geojson")
        }
    }
}
