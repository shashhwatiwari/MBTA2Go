import Foundation
import SwiftData
import CommuteKit

@MainActor @Observable
final class TodayViewModel {
    var loadState: LoadState = .idle
    var nextDepartures: [Prediction] = []
    var activeDisruptions: [Disruption] = []
    var leaveByRecommendation: Date?
    var activeRoute: SavedRoute?
    var reliability: ReliabilityScore?

    private let mbtaClient: MBTAClient
    private let disruptionEngine: DisruptionEngine
    private let routeMatcher: RouteMatcher
    private let commuteWindowResolver: CommuteWindowResolver
    private let reliabilityScorer: ReliabilityScorer

    init(dependencies: AppDependencies) {
        self.mbtaClient = dependencies.mbtaClient
        self.disruptionEngine = dependencies.disruptionEngine
        self.routeMatcher = dependencies.routeMatcher
        self.commuteWindowResolver = dependencies.commuteWindowResolver
        self.reliabilityScorer = dependencies.reliabilityScorer
    }

    func load(routes: [SavedRoute]) async {
        loadState = .loading

        let active = routes.first { route in
            commuteWindowResolver.isWithinCommuteWindow(route)
        } ?? routes.first { $0.isActive }

        guard let route = active else {
            loadState = .loaded
            return
        }

        activeRoute = route

        do {
            async let predictionsTask = mbtaClient.fetchPredictions(
                stopIds: [route.originStopId],
                routeIds: route.lineIds
            )
            async let alertsTask = mbtaClient.fetchAlerts(routeIds: route.lineIds)
            async let schedulesTask = mbtaClient.fetchSchedules(stopIds: [route.originStopId])

            let (predictions, alerts, schedules) = try await (predictionsTask, alertsTask, schedulesTask)

            nextDepartures = predictions

            let allDisruptions = disruptionEngine.merge(alerts: alerts, predictions: predictions)
            activeDisruptions = routeMatcher.disruptions(affecting: route, from: allDisruptions)

            let scores = route.lineIds.map { lineId in
                reliabilityScorer.score(routeId: lineId, predictions: predictions, schedules: schedules)
            }
            reliability = scores.min(by: { $0.onTimePct < $1.onTimePct }) ?? scores.first

            leaveByRecommendation = commuteWindowResolver.leaveByDate(
                for: route,
                nextDeparture: predictions.first?.departure,
                reliability: reliability
            )

            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func refresh(routes: [SavedRoute]) async {
        await load(routes: routes)
    }
}
