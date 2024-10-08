// Views/RoadInfoModalView.swift

import SwiftUI

struct RoadInfoModalView: View {
    @ObservedObject var road: Road
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            // Modal content
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    // Street Name
                    Text(road.name.isEmpty ? "Unknown Road" : road.name)
                        .font(.custom("Quicksand-Bold", size: 18))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    // Ward and Section
                    Text("Ward \(road.ward), Section \(road.section)")
                        .font(.custom("Quicksand-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 16) // Increased spacing after the header

                Divider()
                    .padding(.horizontal)
                    .padding(.bottom, 16) // Added spacing after the divider

                let nextDates = road.nextCleaningDates()

                if nextDates.isEmpty {
                    Text("Unable to get upcoming cleaning dates.")
                        .font(.custom("Quicksand-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    // Title
                    Text("Cleaning Dates:")
                        .font(.custom("Quicksand-Medium", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.bottom, 8) // Added spacing after the title

                    // Cleaning Dates List
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(nextDates, id: \.self) { date in
                            Text(dateString(from: date))
                                .font(.custom("Quicksand-Regular", size: 14))
                                .foregroundColor(color(for: date))
                        }
                    }
                    .padding(.horizontal)

                    // Note about different sides of the street
                    Text("Different sides of the street will have different dates. Often the odd-number addresses (usually west/north) will be cleaned first.")
                        .font(.custom("Quicksand-Regular", size: 11))
                        .foregroundColor(.gray)
                        .lineSpacing(5)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                }

                Spacer()
                    .frame(height: 30) // Added more space before the button

                // Button
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text("OK")
                        .font(.custom("Quicksand-Medium", size: 14))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.customBackground)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 10) // Added spacing at the bottom
            }
            .padding(.top, 20) // Added top padding to the modal content
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 30) // Adjusted horizontal padding for the modal
            .onAppear {
                print("Modal presented for road: \(road.name), Ward: \(road.ward), Section: \(road.section), Cleaning Dates Count: \(road.cleaningDates.count)")
            }
        }
    }

    // Helper function to format the date
    private func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full // E.g., "Tuesday, October 3, 2024"
        return dateFormatter.string(from: date)
    }

    // Helper function to determine the color based on urgency
    private func color(for date: Date) -> Color {
        let calendar = Calendar.current
        let today = Date()
        if let days = calendar.dateComponents([.day], from: today, to: date).day {
            if days <= 3 {
                return .red
            } else if days <= 7 {
                return .yellow
            }
        }
        return .black
    }
}
