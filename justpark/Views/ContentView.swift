// Views/ContentView.swift

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var overlays: [MKOverlay] = []
    @State private var annotations: [MKAnnotation] = []
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
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
            let result = GeoJSONLoader.loadGeoJSONData(fileName: "44_diversey_belmont_final")
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
}
