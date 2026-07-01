import SwiftUI
import CommuteKit

struct SeverityBadge: View {
    let severity: Disruption.Severity

    var body: some View {
        Text(severity.label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch severity {
        case .info: .secondary
        case .minor: .yellow
        case .moderate: .orange
        case .severe: .red
        }
    }
}
