import Foundation
import Observation
import CommuteKit

@MainActor @Observable
final class AppDependencies {
    let mbtaClient: MBTAClient
    let disruptionEngine: DisruptionEngine
    let routeMatcher: RouteMatcher
    let reliabilityScorer: ReliabilityScorer
    let commuteWindowResolver: CommuteWindowResolver
    let alternativeRouteSuggester: AlternativeRouteSuggester
    let locationService: LocationService

    init() {
        self.mbtaClient = MBTAClient(apiKey: Secrets.mbtaAPIKey)
        self.disruptionEngine = DisruptionEngine()
        self.routeMatcher = RouteMatcher()
        self.reliabilityScorer = ReliabilityScorer()
        self.commuteWindowResolver = CommuteWindowResolver()
        self.alternativeRouteSuggester = AlternativeRouteSuggester()
        self.locationService = LocationService()
    }
}
