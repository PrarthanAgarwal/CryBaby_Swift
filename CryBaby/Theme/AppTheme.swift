import SwiftUI

enum AppTheme {
    // MARK: - Colors
    struct Colors {
        static let background = Color(hex: "#E8F9FF")  //  Warm blue background D1F8EF
        static let primary = Color(hex: "#A1E3F9")     // Light peach/cream color
        static let secondary = Color.white.opacity(0.9) // Semi-transparent white
        static let text = Color(hex: "#1f2937")        // Deep charcoal gray for text
        static let textSecondary = Color(hex: "#6b7280") // Muted gray for secondary texst
        static let surface = Color.white.opacity(0.7)    // Semi-transparent white for cards
        
        // Semantic colors
        static let success = Color(hex: "#22c55e")
        static let error = Color(hex: "#ef4444")
        static let warning = Color(hex: "#f59e0b")
    }
    
    // MARK: - Typography
    struct Typography {
        static let titleFont = Font.system(.title, design: .rounded)
        static let headlineFont = Font.system(.headline, design: .rounded)
        static let bodyFont = Font.system(.body, design: .rounded)
        static let captionFont = Font.system(.caption, design: .rounded)
    }
    
    // MARK: - Layout
    struct Layout {
        static let spacing: CGFloat = 12
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 