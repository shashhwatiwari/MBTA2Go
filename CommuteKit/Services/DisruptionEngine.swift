import Foundation

public struct DisruptionEngine {
    public init() {}

    public func merge(alerts: [ServiceAlert], predictions: [Prediction]) -> [Disruption] {
        var disruptions: [Disruption] = []

        for alert in alerts where alert.isCurrentlyActive {
            let severity = mapSeverity(alert.severity)
            let cause = mapCause(alert.effect)
            let activePeriod = alert.activePeriods.first

            disruptions.append(Disruption(
                id: "alert-\(alert.id)",
                routeIds: alert.affectedRouteIds,
                affectedStopIds: alert.affectedStopIds,
                severity: severity,
                cause: cause,
                headline: alert.header,
                detail: alert.description,
                activePeriodStart: activePeriod?.start ?? Date(),
                activePeriodEnd: activePeriod?.end ?? Date().addingTimeInterval(86400),
                updatedAt: alert.updatedAt,
                source: .alertFeed
            ))
        }

        let canceledTrips = predictions.filter { $0.scheduleRelationship == .canceled }
        let canceledByRoute = Dictionary(grouping: canceledTrips, by: \.routeId)

        for (routeId, canceled) in canceledByRoute where canceled.count >= 2 {
            let stopIds = Array(Set(canceled.map(\.stopId)))
            disruptions.append(Disruption(
                id: "computed-cancellations-\(routeId)-\(canceled.count)",
                routeIds: [routeId],
                affectedStopIds: stopIds,
                severity: .moderate,
                cause: .serviceChange,
                headline: "\(canceled.count) trips canceled on \(routeId)",
                detail: nil,
                activePeriodStart: Date(),
                activePeriodEnd: Date().addingTimeInterval(7200),
                updatedAt: Date(),
                source: .computed
            ))
        }

        let heavilyDelayed = predictions.filter { $0.delaySeconds > 600 }
        let delayedByRoute = Dictionary(grouping: heavilyDelayed, by: \.routeId)

        for (routeId, delayed) in delayedByRoute where delayed.count >= 2 {
            let avgDelay = delayed.map(\.delaySeconds).reduce(0, +) / delayed.count
            let stopIds = Array(Set(delayed.map(\.stopId)))
            disruptions.append(Disruption(
                id: "computed-delays-\(routeId)-\(avgDelay)",
                routeIds: [routeId],
                affectedStopIds: stopIds,
                severity: avgDelay > 900 ? .severe : .moderate,
                cause: .delay,
                headline: "Significant delays on \(routeId) (~\(avgDelay / 60) min)",
                detail: nil,
                activePeriodStart: Date(),
                activePeriodEnd: Date().addingTimeInterval(3600),
                updatedAt: Date(),
                source: .computed
            ))
        }

        return disruptions.sorted { $0.severity > $1.severity }
    }

    private func mapSeverity(_ mbtaSeverity: Int) -> Disruption.Severity {
        switch mbtaSeverity {
        case 0...2: .info
        case 3...5: .minor
        case 6...7: .moderate
        default: .severe
        }
    }

    private func mapCause(_ effect: ServiceAlert.Effect) -> Disruption.Cause {
        switch effect {
        case .delay: .delay
        case .detour: .detour
        case .stopClosure, .stationClosure: .stopClosure
        case .serviceChange, .modifiedService, .noService, .stopSuspended: .serviceChange
        case .trackChange, .scheduleChange: .maintenance
        default: .other
        }
    }
}
