import SwiftUI

enum Theme {
    static let primary = Color(red: 0.835, green: 0.557, blue: 0.376)      // warm terracotta
    static let secondary = Color(red: 0.961, green: 0.851, blue: 0.671)    // wheat
    static let background = Color(red: 0.984, green: 0.949, blue: 0.878)   // cream
    static let surface = Color(red: 0.937, green: 0.871, blue: 0.733)      // tan
    static let accent = Color(red: 0.694, green: 0.494, blue: 0.318)       // wood brown
    static let leaf = Color(red: 0.494, green: 0.616, blue: 0.337)         // sage green
    static let sky = Color(red: 0.580, green: 0.737, blue: 0.812)          // soft blue
    static let danger = Color(red: 0.847, green: 0.404, blue: 0.353)       // coral red

    enum Font {
        static let titleLarge = SwiftUI.Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = SwiftUI.Font.system(size: 22, weight: .semibold, design: .rounded)
        static let body = SwiftUI.Font.system(size: 16, weight: .regular, design: .rounded)
        static let caption = SwiftUI.Font.system(size: 13, weight: .regular, design: .rounded)
        static let timer = SwiftUI.Font.system(size: 84, weight: .bold, design: .rounded)
    }

    static func color(fromHex hex: String) -> Color {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = UInt32(s, radix: 16) else { return primary }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }

    static func hex(from color: Color) -> String {
        #if canImport(UIKit)
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        #else
        return "#D58E60"
        #endif
    }
}
