import SwiftUI

struct SplashScreenView: View {
    @Binding var logoOpacity: Double

    var body: some View {
        VStack {
            Image("kbLogo")
                .resizable()
                .scaledToFit()
                .scaleEffect(0.35)
                .opacity(logoOpacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea(edges: .all)
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(logoOpacity: .constant(1.0))
    }
}
