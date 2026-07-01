import SwiftUI
import CommuteKit

struct DepartureCard: View {
    let prediction: Prediction

    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        StatusDot(
                            color: prediction.isDelayed ? .orange : .green,
                            isAnimating: prediction.isDelayed
                        )
                        Text(prediction.routeId)
                            .font(Typography.headline)
                    }

                    if let status = prediction.status {
                        Text(status)
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let minutes = prediction.minutesUntilDeparture {
                        Text(minutes == 0 ? "Now" : "\(minutes) min")
                            .font(.title3.weight(.bold).monospacedDigit())
                            .foregroundStyle(minutes <= 2 ? Theme.red : Theme.textPrimary)
                    }

                    if let departure = prediction.departure {
                        Text(departure, style: .time)
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
    }
}
