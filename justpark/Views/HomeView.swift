// Views/HomeView.swift

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
        UINavigationBar.appearance().compactAppearance = appearance // For iPhone small navigation bar in landscape
        UINavigationBar.appearance().scrollEdgeAppearance = appearance // For large title navigation bar
        UINavigationBar.appearance().tintColor = UIColor(Color.customText) // For back button and other bar button items
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Just Park")
                    .font(.custom("Quicksand-Bold", size: 40))
                    .foregroundColor(.customText)
                    .padding(.top, 40)
                    .padding(.bottom, 5)

                Text("Chicago Edition")
                    .font(.custom("Quicksand-Medium", size: 20))
                    .foregroundColor(.customText)

                Spacer()

                Image("logo") // Replace with your image asset name
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal)

                Spacer()

                // Street Cleaning Button
                NavigationLink(destination: ContentView()) {
                    Text("Street Cleaning")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.customText)
                        .foregroundColor(.customBackground)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .font(.custom("Quicksand-Medium", size: 18))
                }
                .padding(.horizontal, 20)

                // Free Parking Button (currently does nothing)
                Button(action: {
                    // Future implementation for Free Parking
                }) {
                    Text("Free Parking")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.buttonGray)
                        .foregroundColor(.customText)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .font(.custom("Quicksand-Medium", size: 18))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.customBackground.edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color.customText)
    }
}
