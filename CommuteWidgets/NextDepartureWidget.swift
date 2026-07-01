import WidgetKit
import SwiftUI
import CommuteKit

struct NextDepartureWidget: Widget {
    let kind = "NextDeparture"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DepartureProvider()) { entry in
            NextDepartureWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Departure")
        .description("Shows the next departure from your commute stop.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

struct NextDepartureWidgetView: View {
    let entry: DepartureEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .accessoryRectangular:
            rectangularView
        case .accessoryCircular:
            circularView
        default:
            smallView
        }
    }

    private var lineColor: Color {
        Color(hex: entry.lineColor) ?? .gray
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Circle()
                    .fill(lineColor)
                    .frame(width: 10, height: 10)
                Text(entry.lineName)
                    .font(.caption.weight(.semibold))
            }

            Spacer()

            if let minutes = entry.minutesUntilDeparture {
                Text("\(minutes)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("--")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("No data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(lineColor)
                        .frame(width: 10, height: 10)
                    Text(entry.routeName)
                        .font(.caption.weight(.semibold))
                }

                Spacer()

                if let minutes = entry.minutesUntilDeparture {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(minutes)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("--")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                }

                Text(entry.stopName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text("Next")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if let following = entry.followingMinutes {
                    Text("\(following) min")
                        .font(.headline.monospacedDigit())
                } else {
                    Text("--")
                        .font(.headline)
                }
            }
        }
    }

    private var rectangularView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.lineName)
                    .font(.caption.weight(.semibold))
                if let minutes = entry.minutesUntilDeparture {
                    Text("\(minutes) min")
                        .font(.headline.monospacedDigit())
                } else {
                    Text("--")
                        .font(.headline)
                }
            }
            Spacer()
            if let following = entry.followingMinutes {
                Text("then \(following)m")
                    .font(.caption2)
            }
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                if let minutes = entry.minutesUntilDeparture {
                    Text("\(minutes)")
                        .font(.title2.weight(.bold).monospacedDigit())
                    Text("min")
                        .font(.system(size: 8))
                } else {
                    Text("--")
                        .font(.title2.weight(.bold))
                }
            }
        }
    }
}
