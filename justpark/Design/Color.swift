// Design/Color.swift

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }

    static let customBackground = Color(hex: "2f3640")
    static let customBackgroundDarker = Color(hex: "282e36")
    static let customBackgroundDarkest = Color(hex: "21252c")
    static let customText = Color(red: 240 / 255, green: 240 / 255, blue: 234 / 255)
    static let customTextLighter = Color(red: 240 / 255, green: 240 / 255, blue: 234 / 255).opacity(0.7)
    static let buttonGray = Color.gray.opacity(0.7)
}
