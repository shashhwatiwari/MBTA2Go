import Foundation
import SwiftData

public enum Weekday: Int, Codable, CaseIterable, Identifiable, Sendable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    public var id: Int { rawValue }
    public var shortName: String {
        switch self {
        case .sunday: "Sun"
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        }
    }
}

@Model public final class SavedRoute {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var originStopId: String
    public var originStopName: String
    public var destinationStopId: String
    public var destinationStopName: String
    public var lineIds: [String]
    public var daysOfWeek: [Weekday]
    public var leaveWindowStartHour: Int
    public var leaveWindowStartMinute: Int
    public var leaveWindowEndHour: Int
    public var leaveWindowEndMinute: Int
    public var notifyLeadMinutes: Int
    public var isActive: Bool
    public var lastNotifiedDisruptionHash: String?

    public init(
        id: UUID = UUID(),
        name: String,
        originStopId: String,
        originStopName: String = "",
        destinationStopId: String,
        destinationStopName: String = "",
        lineIds: [String],
        daysOfWeek: [Weekday],
        leaveWindowStartHour: Int,
        leaveWindowStartMinute: Int,
        leaveWindowEndHour: Int,
        leaveWindowEndMinute: Int,
        notifyLeadMinutes: Int = 15,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.originStopId = originStopId
        self.originStopName = originStopName
        self.destinationStopId = destinationStopId
        self.destinationStopName = destinationStopName
        self.lineIds = lineIds
        self.daysOfWeek = daysOfWeek
        self.leaveWindowStartHour = leaveWindowStartHour
        self.leaveWindowStartMinute = leaveWindowStartMinute
        self.leaveWindowEndHour = leaveWindowEndHour
        self.leaveWindowEndMinute = leaveWindowEndMinute
        self.notifyLeadMinutes = notifyLeadMinutes
        self.isActive = isActive
    }

    public var leaveWindowStart: DateComponents {
        DateComponents(hour: leaveWindowStartHour, minute: leaveWindowStartMinute)
    }
    public var leaveWindowEnd: DateComponents {
        DateComponents(hour: leaveWindowEndHour, minute: leaveWindowEndMinute)
    }
}
