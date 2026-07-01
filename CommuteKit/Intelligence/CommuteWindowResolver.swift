import Foundation

public struct CommuteWindowResolver {
    public init() {}

    public func leaveByDate(for route: SavedRoute, nextDeparture: Date?, reliability: ReliabilityScore?) -> Date? {
        guard let departure = nextDeparture else { return nil }

        let walkTimeMinutes: Double = 5
        let bufferMinutes: Double = 2
        var paddingMinutes: Double = 0

        if let reliability {
            paddingMinutes = Double(reliability.p90DelaySec) / 60.0
            paddingMinutes = min(paddingMinutes, 15)
        }

        let totalLeadSeconds = (walkTimeMinutes + bufferMinutes + paddingMinutes) * 60
        return departure.addingTimeInterval(-totalLeadSeconds)
    }

    public func isWithinCommuteWindow(_ route: SavedRoute, now: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)

        guard route.daysOfWeek.contains(where: { $0.rawValue == weekday }) else { return false }

        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        let windowStart = route.leaveWindowStartHour * 60 + route.leaveWindowStartMinute
        let windowEnd = route.leaveWindowEndHour * 60 + route.leaveWindowEndMinute

        return currentMinutes >= (windowStart - route.notifyLeadMinutes) && currentMinutes <= windowEnd
    }
}
