import Foundation

public struct Disruption: Hashable, Codable, Identifiable, Sendable {
    public enum Severity: Int, Codable, Comparable, Sendable {
        case info = 0, minor, moderate, severe
        public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

        public var label: String {
            switch self {
            case .info: "Info"
            case .minor: "Minor"
            case .moderate: "Moderate"
            case .severe: "Severe"
            }
        }
    }

    public enum Cause: String, Codable, Sendable {
        case delay, detour, stopClosure, serviceChange, maintenance, other
    }

    public enum Source: String, Codable, Sendable {
        case alertFeed, tripUpdate, computed
    }

    public let id: String
    public let routeIds: [String]
    public let affectedStopIds: [String]
    public let severity: Severity
    public let cause: Cause
    public let headline: String
    public let detail: String?
    public let activePeriodStart: Date
    public let activePeriodEnd: Date
    public let updatedAt: Date
    public let source: Source

    public init(id: String, routeIds: [String], affectedStopIds: [String], severity: Severity, cause: Cause, headline: String, detail: String?, activePeriodStart: Date, activePeriodEnd: Date, updatedAt: Date, source: Source) {
        self.id = id
        self.routeIds = routeIds
        self.affectedStopIds = affectedStopIds
        self.severity = severity
        self.cause = cause
        self.headline = headline
        self.detail = detail
        self.activePeriodStart = activePeriodStart
        self.activePeriodEnd = activePeriodEnd
        self.updatedAt = updatedAt
        self.source = source
    }

    public var activePeriod: DateInterval {
        DateInterval(start: activePeriodStart, end: activePeriodEnd)
    }
}
