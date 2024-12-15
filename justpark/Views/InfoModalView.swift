import SwiftUI

struct InfoModalView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Same background as SettingsView
            Color.customBackground.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Spacer()
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                                .padding(.trailing, 20)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Information")
                            .font(.custom("Quicksand-Bold", size: 24))
                            .foregroundColor(.customText)

                        Text("""
Street sweeping season goes from April 1 to November 30. Sanitation uses mechanical street sweepers to remove debris from streets, weather permitting. They operate weekdays from 9 AM to 2 PM.

The first listed cleaning date typically applies to one side of the street (often the odd-numbered addresses), and the second date applies to the opposite side.

For up-to-date information, please visit the official City of Chicago website. This app is a helpful tool but may not always be current, so always verify details online.

If you find that too many wards are displayed and you only care about a few, you can adjust which wards are shown in the Settings page.
""")
                            .font(.custom("Quicksand-Regular", size: 14))
                            .foregroundColor(.white)
                            .lineSpacing(5)

                        Link("Get up-to-date info",
                             destination: URL(string: "https://www.chicago.gov/city/en/depts/streets/provdrs/streets_san/svcs/street_sweeping2024.html")!)
                            .font(.custom("Quicksand-Medium", size: 14))
                            .foregroundColor(.blue)
                        
                        Link("Chicago Sweeper Tracker",
                             destination: URL(string: "https://www.chicago.gov/city/en/depts/streets/iframe/sweeper_tracker.html")!)
                            .font(.custom("Quicksand-Medium", size: 14))
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Disclaimer below the card
                    Text("Disclaimer: Road One and its developers are not responsible for any fines, tickets, or other consequences that may arise from using this app. Information may be inaccurate or outdated; always verify with official sources.")
                        .font(.custom("Quicksand-Regular", size: 10))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 50)
                }
                .padding(.top, 30)
            }
        }
    }
}
