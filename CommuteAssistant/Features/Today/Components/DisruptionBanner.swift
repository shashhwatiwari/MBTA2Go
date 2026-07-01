import SwiftUI
import CommuteKit

struct DisruptionBanner: View {
    let disruption: Disruption

    var body: some View {
        Card {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(iconColor)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(disruption.headline)
                            .font(Typography.headline)
                        Spacer()
                        SeverityBadge(severity: disruption.severity)
                    }

                    if let detail = disruption.detail {
                        Text(detail)
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(3)
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(borderColor, lineWidth: 2)
        )
    }

    private var iconName: String {
        switch disruption.cause {
        case .delay: "clock.badge.exclamationmark"
        case .detour: "arrow.triangle.branch"
        case .stopClosure: "xmark.circle"
        case .serviceChange: "arrow.triangle.swap"
        case .maintenance: "wrench"
        case .other: "exclamationmark.triangle"
        }
    }

    private var iconColor: Color {
        switch disruption.severity {
        case .info: .secondary
        case .minor: .yellow
        case .moderate: .orange
        case .severe: .red
        }
    }

    private var borderColor: Color {
        iconColor.opacity(0.3)
    }
}
