import Foundation

public struct Stop: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let locationType: LocationType
    public let parentStationId: String?

    public enum LocationType: Int, Codable, Sendable {
        case stop = 0
        case station = 1
        case entranceExit = 2
        case genericNode = 3
        case boardingArea = 4
    }

    public init(id: String, name: String, latitude: Double, longitude: Double, locationType: LocationType, parentStationId: String?) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.locationType = locationType
        self.parentStationId = parentStationId
    }
}
