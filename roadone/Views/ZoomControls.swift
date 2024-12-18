// Views/ZoomControls.swift

import SwiftUI

struct ZoomControls: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 10) {
            zoomButton(iconName: "plus.magnifyingglass") {
                locationManager.zoomIn()
            }

            zoomButton(iconName: "minus.magnifyingglass") {
                locationManager.zoomOut()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }

    @ViewBuilder
    private func zoomButton(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.primary)
                .padding(10)
                .background(.thinMaterial, in: Circle()) // A subtle blurred background
        }
    }
}

