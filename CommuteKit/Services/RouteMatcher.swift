import Foundation

public struct RouteMatcher {
    public init() {}

    public func disruptions(affecting route: SavedRoute, from allDisruptions: [Disruption]) -> [Disruption] {
        allDisruptions.filter { disruption in
            let routeOverlap = !Set(disruption.routeIds).isDisjoint(with: Set(route.lineIds))
            let stopOverlap = disruption.affectedStopIds.contains(route.originStopId) ||
                              disruption.affectedStopIds.contains(route.destinationStopId)
            return routeOverlap || stopOverlap
        }
    }

    public func alerts(affecting route: SavedRoute, from allAlerts: [ServiceAlert]) -> [ServiceAlert] {
        allAlerts.filter { alert in
            let routeOverlap = !Set(alert.affectedRouteIds).isDisjoint(with: Set(route.lineIds))
            let stopOverlap = alert.affectedStopIds.contains(route.originStopId) ||
                              alert.affectedStopIds.contains(route.destinationStopId)
            return (routeOverlap || stopOverlap) && alert.isCurrentlyActive
        }
    }
}
