import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    @AppStorage("ward_43_enabled") private var ward43Enabled: Bool = true
    @AppStorage("ward_44_enabled") private var ward44Enabled: Bool = true
    @AppStorage("ward_46_enabled") private var ward46Enabled: Bool = true
    @AppStorage("ward_48_enabled") private var ward48Enabled: Bool = true
    @AppStorage("ward_47_enabled") private var ward47Enabled: Bool = true
    @AppStorage("ward_42_enabled") private var ward42Enabled: Bool = true
    @AppStorage("ward_2_enabled") private var ward2Enabled: Bool = true
    @AppStorage("ward_27_enabled") private var ward27Enabled: Bool = true
    @AppStorage("ward_32_enabled") private var ward32Enabled: Bool = true


    var body: some View {
        ZStack {
            Color.customBackground.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {

                    // About Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.custom("Quicksand-Bold", size: 24))
                            .foregroundColor(.customText)

                        Text("""
Street sweeping season goes from April 1 to November 30. Sanitation uses mechanical street sweepers to remove debris from streets, weather permitting. They operate weekdays from 9 AM to 2 PM.

For up-to-date information, please visit the official City of Chicago website. This app is a helpful tool but may not always be current, so always verify details online.

This app was created out of frustration with street cleaning schedules and parking tickets. More neighborhoods are being added over time, as they require a lot of effort to input.
""")
                            .font(.custom("Quicksand-Regular", size: 14))
                            .foregroundColor(.white)
                            .lineSpacing(5)

                        Link("Get up-to-date info",
                             destination: URL(string: "https://www.chicago.gov/city/en/depts/streets/provdrs/streets_san/svcs/street_sweeping2024.html")!)
                            .font(.custom("Quicksand-Medium", size: 14))
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)

                    Divider().background(Color.white.opacity(0.3))

                    // Wards Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Wards")
                            .font(.custom("Quicksand-Bold", size: 24))
                            .foregroundColor(.customText)

                        Text("""
Use this link to find your ward:
""")
                            .font(.custom("Quicksand-Regular", size: 14))
                            .foregroundColor(.white)
                            .lineSpacing(4)

                        Link("Chicago Sweeper Tracker",
                             destination: URL(string: "https://www.chicago.gov/city/en/depts/streets/iframe/sweeper_tracker.html")!)
                            .font(.custom("Quicksand-Medium", size: 14))
                            .foregroundColor(.blue)
                            .padding(.bottom, 8)

                        // Ward toggles
                        wardToggle("Ward 2", isOn: $ward2Enabled)
                        wardToggle("Ward 27", isOn: $ward27Enabled)
                        wardToggle("Ward 32", isOn: $ward32Enabled)
                        wardToggle("Ward 42", isOn: $ward42Enabled)
                        wardToggle("Ward 43", isOn: $ward43Enabled)
                        wardToggle("Ward 44", isOn: $ward44Enabled)
                        wardToggle("Ward 46", isOn: $ward46Enabled)
                        wardToggle("Ward 47", isOn: $ward47Enabled)
                        wardToggle("Ward 48", isOn: $ward48Enabled)

                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)

                    // Disclaimer with more line spacing and padding
                    Text("Disclaimer: Chicago Street Cleaning Helper and its developers are not responsible for any fines, tickets, or other consequences that may arise from using this app. Information may be inaccurate or outdated; always verify with official sources.")
                        .font(.custom("Quicksand-Regular", size: 10))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }

    private func wardToggle(_ label: String, isOn: Binding<Bool>) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.custom("Quicksand-Medium", size: 16))
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(Color.customBackgroundLighter)
            }
            .padding(.vertical, 10)
            
            Divider().background(Color.white.opacity(0.3))
        }
        .padding(.horizontal, 5)
    }
}
