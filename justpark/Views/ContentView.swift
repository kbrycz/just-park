// Views/ContentView.swift

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var overlays: [MKOverlay] = []
    @State private var annotations: [MKAnnotation] = []
    @State private var isModalPresented = false
    @State private var modalTitle = ""
    @State private var modalMessage = ""
    @State private var roads: [Road] = []

    var body: some View {
        ZStack {
            MapView(overlays: $overlays, annotations: $annotations)
                .environmentObject(locationManager)
                .edgesIgnoringSafeArea(.all)

            ZoomControls()
                .environmentObject(locationManager)
                .padding(.top, 50)
                .padding(.trailing, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            if isModalPresented {
                RoadInfoModalView(roadName: modalTitle, message: modalMessage, isPresented: $isModalPresented)
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
            let result = GeoJSONLoader.loadGeoJSONData(fileName: "44_diversey_belmont_final") // Use your geojson file
            overlays = result.overlays
            annotations = result.annotations
            roads = result.roads
        }
        .onReceive(locationManager.$selectedRoad) { road in
            if let road = road {
                if let nextDate = road.nextCleaningDate() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .full // Include day of the week
                    let dateString = dateFormatter.string(from: nextDate)
                    modalTitle = road.name
                    modalMessage = "Next street cleaning on \(dateString)"
                } else {
                    modalTitle = road.name
                    modalMessage = "No more street cleaning this year! Check back early next year!"
                }
                withAnimation {
                    isModalPresented = true
                }
                locationManager.selectedRoad = nil
            }
        }
    }
}
