import Foundation
import os

#if canImport(ActivityKit)
import ActivityKit
#endif

#if canImport(ActivityKit)
public struct CommuteActivityAttributes: ActivityAttributes {
    public let routeName: String
    public let lineName: String
    public let lineColor: String
    public let originStop: String
    public let destinationStop: String

    public init(routeName: String, lineName: String, lineColor: String, originStop: String, destinationStop: String) {
        self.routeName = routeName
        self.lineName = lineName
        self.lineColor = lineColor
        self.originStop = originStop
        self.destinationStop = destinationStop
    }

    public struct ContentState: Codable, Hashable {
        public let nextDepartureMinutes: Int?
        public let followingDepartureMinutes: Int?
        public let leaveByTime: Date?
        public let disruptionHeadline: String?
        public let disruptionSeverity: Int?
        public let lastUpdated: Date

        public init(nextDepartureMinutes: Int?, followingDepartureMinutes: Int?, leaveByTime: Date?, disruptionHeadline: String?, disruptionSeverity: Int?, lastUpdated: Date) {
            self.nextDepartureMinutes = nextDepartureMinutes
            self.followingDepartureMinutes = followingDepartureMinutes
            self.leaveByTime = leaveByTime
            self.disruptionHeadline = disruptionHeadline
            self.disruptionSeverity = disruptionSeverity
            self.lastUpdated = lastUpdated
        }
    }
}

@MainActor
public final class LiveActivityService {
    public static let shared = LiveActivityService()

    private let logger = Logger(subsystem: "com.commuteassistant", category: "LiveActivity")
    private var currentActivity: Activity<CommuteActivityAttributes>?

    private init() {}

    public func start(route: SavedRoute, lineName: String, lineColor: String, originName: String, destName: String, state: CommuteActivityAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.warning("Live Activities not enabled")
            return
        }

        let attributes = CommuteActivityAttributes(
            routeName: route.name,
            lineName: lineName,
            lineColor: lineColor,
            originStop: originName,
            destinationStop: destName
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: Date().addingTimeInterval(300)),
                pushType: nil
            )
            currentActivity = activity
            logger.info("Started live activity \(activity.id)")
        } catch {
            logger.error("Failed to start live activity: \(error)")
        }
    }

    public func update(state: CommuteActivityAttributes.ContentState, isSevere: Bool) async {
        guard let activity = currentActivity else { return }

        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(300))

        if isSevere {
            let alertConfig = AlertConfiguration(
                title: "Commute Disruption",
                body: "\(state.disruptionHeadline ?? "Service disruption detected")",
                sound: .default
            )
            await activity.update(content, alertConfiguration: alertConfig)
        } else {
            await activity.update(content)
        }
    }

    public func end() async {
        guard let activity = currentActivity else { return }
        let finalState = CommuteActivityAttributes.ContentState(
            nextDepartureMinutes: nil,
            followingDepartureMinutes: nil,
            leaveByTime: nil,
            disruptionHeadline: nil,
            disruptionSeverity: nil,
            lastUpdated: Date()
        )
        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .after(Date().addingTimeInterval(60))
        )
        currentActivity = nil
    }
}
#endif
