//
//  ZoomControls.swift
//  justpark
//
//  Created by Karl Brycz on 10/1/24.
//

import SwiftUI

struct ZoomControls: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                locationManager.zoomIn()
            }) {
                Image(systemName: "plus.magnifyingglass")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
            }

            Button(action: {
                locationManager.zoomOut()
            }) {
                Image(systemName: "minus.magnifyingglass")
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
            }
        }
    }
}
