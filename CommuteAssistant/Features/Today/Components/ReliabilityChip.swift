import SwiftUI
import CommuteKit

struct ReliabilityChip: View {
    let score: ReliabilityScore

    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reliability")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textSecondary)

                    HStack(spacing: 8) {
                        Text("\(Int(score.onTimePct * 100))% on-time")
                            .font(Typography.headline)

                        Text("typically +\(score.p50DelaySec / 60) min")
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer()

                tierBadge
            }
        }
    }

    private var tierBadge: some View {
        Text(score.reliabilityTier.label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tierColor.opacity(0.15))
            .foregroundStyle(tierColor)
            .clipShape(Capsule())
    }

    private var tierColor: Color {
        switch score.reliabilityTier {
        case .excellent: .green
        case .good: .blue
        case .fair: .orange
        case .poor: .red
        }
    }
}
