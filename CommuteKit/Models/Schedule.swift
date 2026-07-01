import Foundation

public struct Schedule: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let tripId: String
    public let routeId: String
    public let stopId: String
    public let arrival: Date?
    public let departure: Date?
    public let directionId: Int
    public let stopSequence: Int

    public init(id: String, tripId: String, routeId: String, stopId: String, arrival: Date?, departure: Date?, directionId: Int, stopSequence: Int) {
        self.id = id
        self.tripId = tripId
        self.routeId = routeId
        self.stopId = stopId
        self.arrival = arrival
        self.departure = departure
        self.directionId = directionId
        self.stopSequence = stopSequence
    }
}
