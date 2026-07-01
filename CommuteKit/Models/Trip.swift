import Foundation

public struct Trip: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let routeId: String
    public let directionId: Int
    public let headsign: String
    public let name: String?
    public let scheduleRelationship: ScheduleRelationship?

    public enum ScheduleRelationship: String, Codable, Sendable {
        case scheduled = "SCHEDULED"
        case added = "ADDED"
        case unscheduled = "UNSCHEDULED"
        case canceled = "CANCELED"
    }

    public init(id: String, routeId: String, directionId: Int, headsign: String, name: String?, scheduleRelationship: ScheduleRelationship?) {
        self.id = id
        self.routeId = routeId
        self.directionId = directionId
        self.headsign = headsign
        self.name = name
        self.scheduleRelationship = scheduleRelationship
    }
}
