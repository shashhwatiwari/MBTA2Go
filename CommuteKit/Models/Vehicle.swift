import Foundation

public struct Vehicle: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let tripId: String?
    public let routeId: String?
    public let stopId: String?
    public let latitude: Double
    public let longitude: Double
    public let bearing: Double?
    public let currentStatus: Status
    public let currentStopSequence: Int?
    public let updatedAt: Date

    public enum Status: String, Codable, Sendable {
        case incomingAt = "INCOMING_AT"
        case stoppedAt = "STOPPED_AT"
        case inTransitTo = "IN_TRANSIT_TO"
    }

    public init(id: String, tripId: String?, routeId: String?, stopId: String?, latitude: Double, longitude: Double, bearing: Double?, currentStatus: Status, currentStopSequence: Int?, updatedAt: Date) {
        self.id = id
        self.tripId = tripId
        self.routeId = routeId
        self.stopId = stopId
        self.latitude = latitude
        self.longitude = longitude
        self.bearing = bearing
        self.currentStatus = currentStatus
        self.currentStopSequence = currentStopSequence
        self.updatedAt = updatedAt
    }
}
