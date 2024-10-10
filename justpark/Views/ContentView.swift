// Views/ContentView.swift

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var overlays: [MKOverlay] = []
    @State private var annotations: [MKAnnotation] = []
    @State private var isModalPresented = false
    @State private var road: Road?
    @State private var roads: [Road] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            MapView(overlays: $overlays, annotations: $annotations)
                .environmentObject(locationManager)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                        }
                    }
                )

            ZoomControls()
                .environmentObject(locationManager)
                .padding(.top, 50)
                .padding(.trailing, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            if isModalPresented, let road = road {
                RoadInfoModalView(road: road, isPresented: $isModalPresented)
            }
        }
        .navigationBarTitle("Street Cleaning", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                // Future implementation for Info button
            }) {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .foregroundColor(Color.customText)
            }
        )
        .onAppear {
            // Load the GeoJSON data
            DispatchQueue.global(qos: .userInitiated).async {
                let result = GeoJSONLoader.loadGeoJSONData(fileName: "section_8", inSubdirectory: "ward_44")
                DispatchQueue.main.async {
                    overlays = result.overlays
                    annotations = result.annotations
                    roads = result.roads
                    isLoading = false
                    print("Map data loaded successfully.")

                    // Fetch cleaning dates once when the map is loaded
                    fetchCleaningDates()
                }
            }
        }
        .onReceive(locationManager.$selectedRoad) { road in
            if let road = road {
                // Avoid modifying state variables within view updates
                DispatchQueue.main.async {
                    self.road = road
                    withAnimation {
                        self.isModalPresented = true
                    }
                    // Reset the selected road after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        locationManager.selectedRoad = nil
                    }
                }
            }
        }
    }

    private func fetchCleaningDates() {
        // Implement API call here
        // For now, we'll assign dummy data
        print("Fetching cleaning dates from API...")

        let calendar = Calendar.current
        var sampleDates: [Date] = []

        // Create one date per week from today to 12 weeks ahead
        let startDate = Date()
        if let endDate = calendar.date(byAdding: .weekOfYear, value: 12, to: startDate) {
            var currentDate = startDate
            while currentDate <= endDate {
                sampleDates.append(currentDate)
                currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
            }
        }

        for road in roads {
            road.cleaningDates = sampleDates
        }
        for road in roads {
            print("Road ID: \(road.id), Name: \(road.name), Cleaning Dates Count: \(road.cleaningDates.count)")
        }

        print("Assigned sample cleaning dates to roads.")
    }

}
