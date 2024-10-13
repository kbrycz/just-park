// Views/ContentView.swift

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var overlays: [MKOverlay] = []
    @State private var annotations: [MKAnnotation] = []
    @State private var isModalPresented = false
    @State private var section: Section?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            MapView(overlays: $overlays, annotations: $annotations, section: $section)
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

            if isModalPresented, let section = section {
                SectionInfoModalView(section: section, isPresented: $isModalPresented)
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
                let result = GeoJSONLoader.loadSectionGeoJSONData(fileName: "section_9", inSubdirectory: "ward_44")
                DispatchQueue.main.async {
                    overlays = result.overlays
                    annotations = result.annotations
                    section = result.section
                    isLoading = false
                    print("Map data loaded successfully.")

                    // Fetch cleaning dates once when the map is loaded
                    fetchCleaningDates()
                }
            }
        }
        .onReceive(locationManager.$selectedSection) { selectedSection in
            if let selectedSection = selectedSection {
                DispatchQueue.main.async {
                    self.section = selectedSection
                    withAnimation {
                        self.isModalPresented = true
                    }
                    // Reset the selected section after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        locationManager.selectedSection = nil
                    }
                }
            }
        }
    }

    private func fetchCleaningDates() {
        print("Fetching cleaning dates from API...")

        let calendar = Calendar.current
        var sampleDates: [Date] = []

        // Add dates for testing
        let today = Date()
        if let dateIn2Days = calendar.date(byAdding: .day, value: 2, to: today),
           let dateIn5Days = calendar.date(byAdding: .day, value: 5, to: today),
           let dateIn10Days = calendar.date(byAdding: .day, value: 10, to: today) {
            sampleDates.append(contentsOf: [dateIn2Days, dateIn5Days, dateIn10Days])
        }

        section?.cleaningDates = sampleDates
        print("Assigned sample cleaning dates to section.")

        // Force the overlays to update
        if let sectionOverlay = section?.polygon as? SectionOverlay {
            // Create a new overlay to force renderer to update
            let pointCount = sectionOverlay.pointCount
            var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
            sectionOverlay.getCoordinates(&coordinates, range: NSRange(location: 0, length: pointCount))

            let newOverlay = SectionOverlay(coordinates: coordinates, count: pointCount)
            newOverlay.section = section
            newOverlay.title = sectionOverlay.title

            // Update the section's polygon
            section?.polygon = newOverlay

            // Update the overlays
            overlays = [newOverlay]
        }
    }
}
