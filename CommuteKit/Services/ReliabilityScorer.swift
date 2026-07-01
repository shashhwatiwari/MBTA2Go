import Foundation

public struct ReliabilityScorer {
    public init() {}

    public func score(routeId: String, predictions: [Prediction], schedules: [Schedule]) -> ReliabilityScore {
        let matchedDelays = matchPredictionsToSchedules(predictions: predictions, schedules: schedules)

        guard !matchedDelays.isEmpty else {
            return ReliabilityScore(
                routeId: routeId,
                windowStart: Date().addingTimeInterval(-14 * 86400),
                windowEnd: Date(),
                onTimePct: 1.0,
                p50DelaySec: 0,
                p90DelaySec: 0,
                sampleCount: 0
            )
        }

        let sortedDelays = matchedDelays.sorted()
        let onTimeCount = sortedDelays.filter { abs($0) <= 180 }.count
        let onTimePct = Double(onTimeCount) / Double(sortedDelays.count)
        let p50 = sortedDelays[sortedDelays.count / 2]
        let p90Index = min(Int(Double(sortedDelays.count) * 0.9), sortedDelays.count - 1)
        let p90 = sortedDelays[p90Index]

        return ReliabilityScore(
            routeId: routeId,
            windowStart: Date().addingTimeInterval(-14 * 86400),
            windowEnd: Date(),
            onTimePct: onTimePct,
            p50DelaySec: p50,
            p90DelaySec: p90,
            sampleCount: sortedDelays.count
        )
    }

    private func matchPredictionsToSchedules(predictions: [Prediction], schedules: [Schedule]) -> [Int] {
        var delays: [Int] = []

        for prediction in predictions {
            guard let predDeparture = prediction.departure else { continue }

            if let matchingSchedule = schedules.first(where: { $0.tripId == prediction.tripId && $0.stopId == prediction.stopId }),
               let schedDeparture = matchingSchedule.departure {
                let delay = Int(predDeparture.timeIntervalSince(schedDeparture))
                delays.append(delay)
            }
        }

        return delays
    }
}
