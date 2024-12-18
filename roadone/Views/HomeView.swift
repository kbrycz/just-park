import SwiftUI

struct HomeView: View {
    init() {
        // Customize UINavigationBar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.customBackground)
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Quicksand-Bold", size: 18)!,
            .foregroundColor: UIColor(Color.customText)
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "Quicksand-Bold", size: 34)!,
            .foregroundColor: UIColor(Color.customText)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.customText)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background image with tint and blur
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.customBackground.opacity(0.8))
                    .blur(radius: 6)

                // Top Content: Title, Subtitle, Logo
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)

                    Text("Road One")
                        .font(.custom("Quicksand-Bold", size: 40))
                        .foregroundColor(.customText)

                    Text("Chicago Street Cleaning")
                        .font(.custom("Quicksand-Medium", size: 20))
                        .foregroundColor(.customText)

                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .padding(.bottom, 30)

                    Spacer()
                }

                // Bottom Buttons: Anchored towards the bottom
                VStack(spacing: 15) {
                    let buttonWidth = UIScreen.main.bounds.width * 0.8

                    NavigationLink(destination: ContentView()) {
                        Text("Street Cleaning")
                            .font(.custom("Quicksand-Medium", size: 18))
                            .foregroundColor(.customBackground)
                            .padding()
                            .frame(width: buttonWidth)
                            .background(Color.customText)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                            .font(.custom("Quicksand-Medium", size: 18))
                            .foregroundColor(.customText)
                            .padding()
                            .frame(width: buttonWidth)
                            .background(Color.buttonGray)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    // Dummy links for Terms of Service and Privacy Policy,
                    // non-clickable text separated from clickable bold terms.
                    HStack(spacing: 5) {
                        Text("View our")
                            .font(.custom("Quicksand-Regular", size: 12))
                            .foregroundColor(Color.white.opacity(0.5))

                        Button(action: {}) {
                            Text("Terms of Service")
                                .font(.custom("Quicksand-Regular", size: 12))
                                .bold()
                                .foregroundColor(Color.white.opacity(0.5))
                        }

                        Text("and")
                            .font(.custom("Quicksand-Regular", size: 12))
                            .foregroundColor(Color.white.opacity(0.5))

                        Button(action: {}) {
                            Text("Privacy Policy")
                                .font(.custom("Quicksand-Regular", size: 12))
                                .bold()
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                    }
                    .padding(.top, 10)

                    Spacer().frame(height: 50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color.customText)
    }
}
