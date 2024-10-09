// Views/RoadInfoModalView.swift

import SwiftUI

struct RoadInfoModalView: View {
    var road: Road
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            // Modal content
            VStack(spacing: 20) {
                Text(road.name.isEmpty ? "Unknown Road" : road.name)
                    .font(.custom("Quicksand-Bold", size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                let nextDates = road.nextCleaningDates()

                if nextDates.isEmpty {
                    Text("Unable to get upcoming cleaning dates.")
                        .font(.custom("Quicksand-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(nextDates, id: \.self) { date in
                            HStack {
                                Text(dateString(from: date))
                                    .font(.custom("Quicksand-Regular", size: 14))
                                    .foregroundColor(color(for: date))
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }

                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text("OK")
                        .font(.custom("Quicksand-Medium", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customBackground)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
    }

    // Helper function to format the date
    func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full // E.g., "Tuesday, October 3, 2023"
        return dateFormatter.string(from: date)
    }

    // Helper function to determine the color based on urgency
    func color(for date: Date) -> Color {
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
