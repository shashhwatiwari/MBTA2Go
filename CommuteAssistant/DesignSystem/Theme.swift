import SwiftUI

enum Theme {
    static let red = Color(hex: "DA291C") ?? .red
    static let orange = Color(hex: "ED8B00") ?? .orange
    static let blue = Color(hex: "003DA5") ?? .blue
    static let green = Color(hex: "00843D") ?? .green
    static let silver = Color(hex: "7C878E") ?? .gray

    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)

    static func lineColor(for lineId: String) -> Color {
        switch lineId {
        case "Red": red
        case "Orange": orange
        case "Blue": blue
        case let id where id.hasPrefix("Green"): green
        case "Mattapan": red
        default: silver
        }
    }
}
