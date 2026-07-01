import Foundation

public struct ReliabilityScore: Codable, Hashable, Sendable {
    public let routeId: String
    public let windowStart: Date
    public let windowEnd: Date
    public let onTimePct: Double
    public let p50DelaySec: Int
    public let p90DelaySec: Int
    public let sampleCount: Int

    public init(routeId: String, windowStart: Date, windowEnd: Date, onTimePct: Double, p50DelaySec: Int, p90DelaySec: Int, sampleCount: Int) {
        self.routeId = routeId
        self.windowStart = windowStart
        self.windowEnd = windowEnd
        self.onTimePct = onTimePct
        self.p50DelaySec = p50DelaySec
        self.p90DelaySec = p90DelaySec
        self.sampleCount = sampleCount
    }

    public var window: DateInterval {
        DateInterval(start: windowStart, end: windowEnd)
    }

    public var reliabilityTier: Tier {
        switch onTimePct {
        case 0.9...: .excellent
        case 0.75...: .good
        case 0.6...: .fair
        default: .poor
        }
    }

    public enum Tier: String, Sendable {
        case excellent, good, fair, poor

        public var label: String {
            switch self {
            case .excellent: "Excellent"
            case .good: "Good"
            case .fair: "Fair"
            case .poor: "Poor"
            }
        }
    }
}
