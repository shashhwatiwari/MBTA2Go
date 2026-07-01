import Foundation

public struct ServiceAlert: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let effect: Effect
    public let severity: Int
    public let lifecycle: Lifecycle
    public let header: String
    public let description: String?
    public let url: URL?
    public let affectedRouteIds: [String]
    public let affectedStopIds: [String]
    public let activePeriods: [ActivePeriod]
    public let updatedAt: Date
    public let createdAt: Date

    public enum Effect: String, Codable, Sendable {
        case accessIssue = "ACCESS_ISSUE"
        case delay = "DELAY"
        case detour = "DETOUR"
        case dockClosure = "DOCK_CLOSURE"
        case dockIssue = "DOCK_ISSUE"
        case elevatorClosure = "ELEVATOR_CLOSURE"
        case escalatorClosure = "ESCALATOR_CLOSURE"
        case extraService = "EXTRA_SERVICE"
        case facilityIssue = "FACILITY_ISSUE"
        case modifiedService = "MODIFIED_SERVICE"
        case noService = "NO_SERVICE"
        case policyChange = "POLICY_CHANGE"
        case scheduleChange = "SCHEDULE_CHANGE"
        case serviceChange = "SERVICE_CHANGE"
        case shuttleBus = "SHUTTLE"
        case snowRoute = "SNOW_ROUTE"
        case stationClosure = "STATION_CLOSURE"
        case stationIssue = "STATION_ISSUE"
        case stopClosure = "STOP_CLOSURE"
        case stopMoved = "STOP_MOVED"
        case stopSuspended = "SUSPENSION"
        case summaryOfService = "SUMMARY"
        case trackChange = "TRACK_CHANGE"
        case unknown = "UNKNOWN_EFFECT"
    }

    public enum Lifecycle: String, Codable, Sendable {
        case new = "NEW"
        case ongoing = "ONGOING"
        case ongoingUpcoming = "ONGOING_UPCOMING"
        case upcoming = "UPCOMING"
    }

    public struct ActivePeriod: Hashable, Codable, Sendable {
        public let start: Date?
        public let end: Date?

        public init(start: Date?, end: Date?) {
            self.start = start
            self.end = end
        }
    }

    public init(id: String, effect: Effect, severity: Int, lifecycle: Lifecycle, header: String, description: String?, url: URL?, affectedRouteIds: [String], affectedStopIds: [String], activePeriods: [ActivePeriod], updatedAt: Date, createdAt: Date) {
        self.id = id
        self.effect = effect
        self.severity = severity
        self.lifecycle = lifecycle
        self.header = header
        self.description = description
        self.url = url
        self.affectedRouteIds = affectedRouteIds
        self.affectedStopIds = affectedStopIds
        self.activePeriods = activePeriods
        self.updatedAt = updatedAt
        self.createdAt = createdAt
    }

    public var isCurrentlyActive: Bool {
        let now = Date()
        return activePeriods.contains { period in
            let afterStart = period.start.map { now >= $0 } ?? true
            let beforeEnd = period.end.map { now <= $0 } ?? true
            return afterStart && beforeEnd
        }
    }
}
