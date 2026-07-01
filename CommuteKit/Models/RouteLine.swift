import Foundation
import SwiftUI

public struct RouteLine: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let longName: String
    public let shortName: String
    public let type: TransitType
    public let color: String
    public let textColor: String
    public let sortOrder: Int

    public enum TransitType: Int, Codable, Sendable {
        case lightRail = 0
        case heavyRail = 1
        case commuterRail = 2
        case bus = 3
        case ferry = 4
    }

    public init(id: String, longName: String, shortName: String, type: TransitType, color: String, textColor: String, sortOrder: Int) {
        self.id = id
        self.longName = longName
        self.shortName = shortName
        self.type = type
        self.color = color
        self.textColor = textColor
        self.sortOrder = sortOrder
    }

    public var displayColor: Color {
        Color(hex: color) ?? .gray
    }
}

public extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        guard hex.count == 6, let int = UInt64(hex, radix: 16) else { return nil }
        self.init(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255
        )
    }
}
