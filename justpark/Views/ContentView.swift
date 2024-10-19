// ContentView.swift

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var overlays: [MKOverlay] = []
    @State private var annotations: [MKAnnotation] = []
    @State private var isModalPresented = false
    @State private var sections: [Section] = []
    @State private var selectedSection: Section?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            MapView(overlays: $overlays, annotations: $annotations, sections: $sections)
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

            if isModalPresented, let section = selectedSection {
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
                    .foregroundColor(Color.primary)
            }
        )
        .onAppear {
            // Load all sections
            DispatchQueue.global(qos: .userInitiated).async {
                let result = GeoJSONLoader.loadAllSections()
                DispatchQueue.main.async {
                    sections = result.sections
                    isLoading = false
                    print("All sections loaded successfully.")

                    // Fetch cleaning dates for each section
                    fetchCleaningDates()
                }
            }
        }
        .onReceive(locationManager.$selectedSection) { selectedSection in
            if let selectedSection = selectedSection {
                // Use DispatchQueue to avoid updating state during view updates
                DispatchQueue.main.async {
                    self.selectedSection = selectedSection
                    withAnimation {
                        self.isModalPresented = true
                    }
                }
                // Reset the selected section after a delay to avoid warnings
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.locationManager.selectedSection = nil
                }
            }
        }
    }

    private func fetchCleaningDates() {
        print("Fetching cleaning dates from API...")

        let calendar = Calendar.current
        let today = Date()

        for section in sections {
            var sampleDates: [Date] = []

            // Add dates for testing
            if let dateIn2Days = calendar.date(byAdding: .day, value: 10, to: today),
               let dateIn5Days = calendar.date(byAdding: .day, value: 11, to: today),
               let dateIn10Days = calendar.date(byAdding: .day, value: 10, to: today) {
                sampleDates.append(contentsOf: [dateIn2Days, dateIn5Days, dateIn10Days])
            }

            section.cleaningDates = sampleDates
            print("Assigned sample cleaning dates to section \(section.sectionNumber).")
        }

        // Force the overlays to update
        updateOverlays()
    }

    private func updateOverlays() {
        overlays = sections.flatMap { $0.overlays }
    }
}
