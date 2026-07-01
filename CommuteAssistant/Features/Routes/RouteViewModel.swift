import Foundation
import SwiftData
import CommuteKit

@MainActor @Observable
final class RouteViewModel {
    var loadState: LoadState = .idle
    var predictions: [Prediction] = []
    var reliability: ReliabilityScore?
    var alternatives: [SuggestedRoute] = []
    var disruptions: [Disruption] = []
    var stopSearchResults: [Stop] = []
    var availableLines: [RouteLine] = []

    private let mbtaClient: MBTAClient
    private let disruptionEngine: DisruptionEngine
    private let routeMatcher: RouteMatcher
    private let reliabilityScorer: ReliabilityScorer
    private let alternativeRouteSuggester: AlternativeRouteSuggester

    init(dependencies: AppDependencies) {
        self.mbtaClient = dependencies.mbtaClient
        self.disruptionEngine = dependencies.disruptionEngine
        self.routeMatcher = dependencies.routeMatcher
        self.reliabilityScorer = dependencies.reliabilityScorer
        self.alternativeRouteSuggester = dependencies.alternativeRouteSuggester
    }

    func loadDetail(for route: SavedRoute) async {
        loadState = .loading
        do {
            async let predsTask = mbtaClient.fetchPredictions(stopIds: [route.originStopId], routeIds: route.lineIds)
            async let alertsTask = mbtaClient.fetchAlerts(routeIds: route.lineIds)
            async let schedsTask = mbtaClient.fetchSchedules(stopIds: [route.originStopId])

            let (preds, alerts, scheds) = try await (predsTask, alertsTask, schedsTask)
            predictions = preds

            let allDisruptions = disruptionEngine.merge(alerts: alerts, predictions: preds)
            disruptions = routeMatcher.disruptions(affecting: route, from: allDisruptions)

            let scores = route.lineIds.map { lineId in
                reliabilityScorer.score(routeId: lineId, predictions: preds, schedules: scheds)
            }
            reliability = scores.min(by: { $0.onTimePct < $1.onTimePct }) ?? scores.first

            alternatives = alternativeRouteSuggester.suggest(for: route, disruptions: disruptions)
            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func searchStops(query: String) async {
        guard query.count >= 2 else {
            stopSearchResults = []
            return
        }
        do {
            stopSearchResults = try await mbtaClient.searchStops(query: query)
        } catch {
            stopSearchResults = []
        }
    }

    func loadLines() async {
        do {
            availableLines = try await mbtaClient.fetchRoutes()
        } catch {
            availableLines = []
        }
    }
}
