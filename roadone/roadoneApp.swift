import SwiftUI

@main
struct roadoneApp: App {
    // Splash screen states
    @State private var isShowingSplash = true
    @State private var logoOpacity = 1.0

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Your main HomeView
                HomeView()

                // Splash screen on top (if still showing)
                if isShowingSplash {
                    SplashScreenView(logoOpacity: $logoOpacity)
                        .onAppear {
                            // Delay for 3 seconds, then animate the logo fade-out
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    logoOpacity = 0.0
                                }
                                // Remove the splash after the fade-out finishes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    isShowingSplash = false
                                }
                            }
                        }
                }
            }
            .edgesIgnoringSafeArea(.all) // Let the splash cover the entire screen
        }
    }
}
