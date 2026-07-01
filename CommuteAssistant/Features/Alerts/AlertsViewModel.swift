import Foundation
import CommuteKit

@MainActor @Observable
final class AlertsViewModel {
    var loadState: LoadState = .idle
    var alerts: [ServiceAlert] = []
    var selectedLineFilter: String?
    var selectedCategory: String?

    private let mbtaClient: MBTAClient
    private var routeToCategory: [String: String] = [:]

    init(dependencies: AppDependencies) {
        self.mbtaClient = dependencies.mbtaClient
    }

    var categories: [String] {
        let present = Set(alerts.flatMap { $0.affectedRouteIds }.compactMap { routeToCategory[$0] })
        let order = ["Subway", "Light Rail", "Commuter Rail", "Bus", "Ferry"]
        return order.filter { present.contains($0) }
    }

    var groupedAlerts: [(category: String, alerts: [ServiceAlert])] {
        let filtered: [ServiceAlert]
        if let line = selectedLineFilter {
            filtered = alerts.filter { $0.affectedRouteIds.contains(line) }
        } else {
            filtered = alerts
        }

        var buckets: [String: [ServiceAlert]] = [:]
        for alert in filtered {
            let cats = Set(alert.affectedRouteIds.compactMap { routeToCategory[$0] })
            let alertCategories = cats.isEmpty ? ["Other"] : cats
            for cat in alertCategories {
                if let selectedCategory, cat != selectedCategory { continue }
                buckets[cat, default: []].append(alert)
            }
        }

        if let selectedCategory {
            if let items = buckets[selectedCategory] {
                return [(selectedCategory, items)]
            }
            return []
        }

        let order = ["Subway", "Light Rail", "Commuter Rail", "Bus", "Ferry", "Other"]
        return order.compactMap { cat in
            guard let items = buckets[cat], !items.isEmpty else { return nil }
            return (cat, items)
        }
    }

    func load() async {
        loadState = .loading
        do {
            async let alertsFetch = mbtaClient.fetchAlerts()
            async let routesFetch = mbtaClient.fetchRoutes()

            let (fetchedAlerts, routes) = try await (alertsFetch, routesFetch)
            alerts = fetchedAlerts

            var mapping: [String: String] = [:]
            for route in routes {
                mapping[route.id] = categoryName(for: route.type)
            }
            routeToCategory = mapping

            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    private func categoryName(for type: RouteLine.TransitType) -> String {
        switch type {
        case .heavyRail:    return "Subway"
        case .lightRail:    return "Light Rail"
        case .commuterRail: return "Commuter Rail"
        case .bus:          return "Bus"
        case .ferry:        return "Ferry"
        }
    }
}
