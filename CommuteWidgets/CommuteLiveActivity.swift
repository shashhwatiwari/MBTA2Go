import ActivityKit
import WidgetKit
import SwiftUI
import CommuteKit

struct CommuteLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CommuteActivityAttributes.self) { context in
            lockScreenView(context: context)
                .activityBackgroundTint(Color(hex: context.attributes.lineColor)?.opacity(0.1) ?? .clear)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: context.attributes.lineColor) ?? .gray)
                            .frame(width: 10, height: 10)
                        Text(context.attributes.lineName)
                            .font(.caption.weight(.semibold))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let minutes = context.state.nextDepartureMinutes {
                        Text("\(minutes) min")
                            .font(.headline.monospacedDigit())
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    if let headline = context.state.disruptionHeadline {
                        Text(headline)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.originStop)
                                .font(.caption2)
                            Text("→ \(context.attributes.destinationStop)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let leaveBy = context.state.leaveByTime {
                            VStack(alignment: .trailing) {
                                Text("Leave by")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(leaveBy, style: .time)
                                    .font(.caption.weight(.semibold))
                            }
                        }
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: context.attributes.lineColor) ?? .gray)
                        .frame(width: 8, height: 8)
                    Text(context.attributes.lineName)
                        .font(.caption2.weight(.semibold))
                }
            } compactTrailing: {
                if let minutes = context.state.nextDepartureMinutes {
                    Text("\(minutes)m")
                        .font(.caption.weight(.bold).monospacedDigit())
                }
            } minimal: {
                if let minutes = context.state.nextDepartureMinutes {
                    Text("\(minutes)")
                        .font(.caption2.weight(.bold).monospacedDigit())
                }
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<CommuteActivityAttributes>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: context.attributes.lineColor) ?? .gray)
                        .frame(width: 12, height: 12)
                    Text(context.attributes.routeName)
                        .font(.headline)
                }

                Text("\(context.attributes.originStop) → \(context.attributes.destinationStop)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let headline = context.state.disruptionHeadline {
                    Text(headline)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .lineLimit(2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let minutes = context.state.nextDepartureMinutes {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(minutes)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("min")
                            .font(.caption)
                    }
                }

                if let following = context.state.followingDepartureMinutes {
                    Text("then \(following) min")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if let leaveBy = context.state.leaveByTime {
                    Text("Leave by \(leaveBy, style: .time)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
    }
}
