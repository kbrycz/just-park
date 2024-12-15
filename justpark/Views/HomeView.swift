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
                // Background image with stronger tint and blur
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Color.customBackground.opacity(0.8) // Stronger tint
                    )
                    .blur(radius: 6) // Slightly stronger blur

                VStack(spacing: 20) {
                    Spacer().frame(height: 40) // Top spacing

                    Text("Road One")
                        .font(.custom("Quicksand-Bold", size: 40))
                        .foregroundColor(.customText)

                    Text("Chicago Street Cleaning")
                        .font(.custom("Quicksand-Medium", size: 20))
                        .foregroundColor(.customText)
                        .padding(.bottom, 20)

                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)

                    // Use a fixed width for the buttons (80% of screen width)
                    let buttonWidth = UIScreen.main.bounds.width * 0.8

                    // Street Cleaning Button
                    NavigationLink(destination: ContentView()) {
                        Text("Street Cleaning")
                            .font(.custom("Quicksand-Medium", size: 18))
                            .foregroundColor(.customBackground)
                            .padding()
                            .frame(width: buttonWidth)   // Fixed width
                            .background(Color.customText)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    // Settings Button
                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                            .font(.custom("Quicksand-Medium", size: 18))
                            .foregroundColor(.customText)
                            .padding()
                            .frame(width: buttonWidth)   // Fixed width
                            .background(Color.buttonGray)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    Spacer().frame(height: 50)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color.customText)
    }
}
