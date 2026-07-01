import SwiftUI

enum Typography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title2, design: .rounded, weight: .semibold)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.caption, design: .default)
    static let countdown = Font.system(size: 48, weight: .bold, design: .rounded).monospacedDigit()
}
