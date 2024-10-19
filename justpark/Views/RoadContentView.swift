// Views/RoadContentView.swift

import SwiftUI
import MapKit

struct RoadContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var roadOverlays: [MKOverlay] = []
    @State private var roadAnnotations: [MKAnnotation] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            RoadMapView(overlays: $roadOverlays, annotations: $roadAnnotations)
                .environmentObject(locationManager)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView("Loading Roads...")
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
        }
        .navigationBarTitle("Road Debug View", displayMode: .inline)
        .onAppear {
            // Load the GeoJSON data for roads
            DispatchQueue.global(qos: .userInitiated).async {
                let result = GeoJSONLoaderRoad.loadRoadGeoJSONData(fileName: "section_8", inSubdirectory: "ward_44")
                DispatchQueue.main.async {
                    roadOverlays = result.overlays
                    roadAnnotations = result.annotations
                    isLoading = false
                    print("Road data loaded successfully.")
                }
            }
        }
    }
}
