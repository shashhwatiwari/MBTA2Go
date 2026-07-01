import Foundation

public struct Prediction: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let tripId: String
    public let routeId: String
    public let stopId: String
    public let arrival: Date?
    public let departure: Date?
    public let scheduleRelationship: ScheduleRelationship
    public let delaySeconds: Int
    public let directionId: Int
    public let status: String?

    public enum ScheduleRelationship: String, Codable, Sendable {
        case scheduled = "SCHEDULED"
        case added = "ADDED"
        case skipped = "SKIPPED"
        case canceled = "CANCELED"
        case noData = "NO_DATA"
    }

    public init(id: String, tripId: String, routeId: String, stopId: String, arrival: Date?, departure: Date?, scheduleRelationship: ScheduleRelationship, delaySeconds: Int, directionId: Int, status: String?) {
        self.id = id
        self.tripId = tripId
        self.routeId = routeId
        self.stopId = stopId
        self.arrival = arrival
        self.departure = departure
        self.scheduleRelationship = scheduleRelationship
        self.delaySeconds = delaySeconds
        self.directionId = directionId
        self.status = status
    }

    public var minutesUntilDeparture: Int? {
        guard let departure else { return nil }
        return max(0, Int(departure.timeIntervalSinceNow / 60))
    }

    public var isDelayed: Bool { delaySeconds > 180 }
}
