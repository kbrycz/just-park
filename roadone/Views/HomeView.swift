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
                // Background image (blur + tint)
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: [.all])
                    .overlay(Color.customBackground.opacity(0.8))
                    .blur(radius: 6)

                GeometryReader { geometry in
                    let minDimension = min(geometry.size.width, geometry.size.height)
                    let isPad = minDimension > 600

                    let titleFontSize: CGFloat = isPad ? 48 : 28
                    let subTitleFontSize: CGFloat = isPad ? 24 : 16
                    let buttonWidth = isPad
                        ? minDimension * 0.6
                        : minDimension * 0.7
                    let maxContentWidth: CGFloat = isPad ? 1200 : .infinity

                    VStack(spacing: 10) {
                        // Top Content: Title, Subtitle, and Logo
                        Spacer()
                        VStack(spacing: 10) {
                            Text("Chicago Street Cleaning")
                                .font(.custom("Quicksand-Bold", size: titleFontSize))
                                .foregroundColor(.customText)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.8)

                            Text("Say goodbye to those parking tickets!")
                                .font(.custom("Quicksand-Medium", size: subTitleFontSize))
                                .foregroundColor(.customText)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.85)

                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: isPad ? 500 : 250)
                                .padding(.top, 20)
                        }

                        Spacer()

                        // Bottom Content: Buttons and TOS
                        VStack(spacing: 16) {
                            NavigationLink(destination: ContentView()) {
                                Text("Street Cleaning")
                                    .font(.custom("Quicksand-Medium", size: subTitleFontSize))
                                    .foregroundColor(.customBackground)
                                    .padding()
                                    .frame(width: buttonWidth)
                                    .background(Color.customText)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }

                            NavigationLink(destination: SettingsView()) {
                                Text("Settings")
                                    .font(.custom("Quicksand-Medium", size: subTitleFontSize))
                                    .foregroundColor(.customText)
                                    .padding()
                                    .frame(width: buttonWidth)
                                    .background(Color.buttonGray)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }

                            HStack(spacing: 3) {
                                Text("View our")
                                    .font(.custom("Quicksand-Regular", size: isPad ? 14 : 12))
                                    .foregroundColor(Color.white.opacity(0.5))

                                Button(action: {
                                    if let url = URL(string: "https://www.termsfeed.com/live/a3fa6538-8014-4a5e-b9db-246dfb527dfe") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Privacy Policy")
                                        .font(.custom("Quicksand-Regular", size: isPad ? 14 : 12))
                                        .bold()
                                        .foregroundColor(Color.white.opacity(0.5))
                                }

                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: maxContentWidth)
                        .padding(.bottom, isPad ? 140 : 30)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxHeight: .infinity, alignment: .top) // Align top for the main content
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color.customText)
    }
}
