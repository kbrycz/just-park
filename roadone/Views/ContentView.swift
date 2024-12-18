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
    @State private var showInfoModal = false

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
                    .id(section.id)
            }

        }
        .navigationBarTitle("Street Cleaning", displayMode: .inline)
        // In the body or after your other modifiers:
        .navigationBarItems(trailing:
            Button(action: {
                showInfoModal = true
            }) {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .foregroundColor(Color.customText)
            }
        )
        .sheet(isPresented: $showInfoModal) {
            InfoModalView()
        }
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
            // Generate a random number between 1 and 13 for the first cleaning date.
            // That way we can have a second cleaning date the next day without exceeding 14 days out.
            let randomDaysOffset = Int.random(in: 1...13)
            
            guard let firstDate = calendar.date(byAdding: .day, value: randomDaysOffset, to: today),
                  let secondDate = calendar.date(byAdding: .day, value: 1, to: firstDate) else {
                // In case of any unexpected date calculation failure, continue to next section.
                continue
            }

            // Assign these two consecutive dates to the section
            section.cleaningDates = [firstDate, secondDate]

            print("Assigned random cleaning dates to section \(section.sectionNumber):")
            print(" - \(firstDate)")
            print(" - \(secondDate)")
        }

        // Force the overlays to update so colors refresh according to the new random dates
        updateOverlays()
    }



    private func updateOverlays() {
        overlays = sections.flatMap { $0.overlays }
    }
}
