// Views/RoadInfoModalView.swift

import SwiftUI

struct RoadInfoModalView: View {
    var roadName: String
    var message: String
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
                Text(roadName)
                    .font(.custom("Quicksand-Bold", size: 18)) // Reduced font size
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.custom("Quicksand-Regular", size: 14)) // Reduced font size
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

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
}
