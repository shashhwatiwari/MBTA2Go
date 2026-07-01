import Foundation

// MARK: - JSON:API Envelope

struct JSONAPIResponse<T: Decodable>: Decodable {
    let data: [T]
}

// MARK: - Prediction Resource

struct PredictionResource: Decodable {
    let id: String
    let attributes: Attributes
    let relationships: Relationships?

    struct Attributes: Decodable {
        let arrivalTime: String?
        let departureTime: String?
        let directionId: Int?
        let scheduleRelationship: String?
        let status: String?

        enum CodingKeys: String, CodingKey {
            case arrivalTime = "arrival_time"
            case departureTime = "departure_time"
            case directionId = "direction_id"
            case scheduleRelationship = "schedule_relationship"
            case status
        }
    }

    struct Relationships: Decodable {
        let route: Relationship?
        let stop: Relationship?
        let trip: Relationship?
    }

    func toPrediction() -> Prediction {
        let iso = ISO8601DateFormatter()
        return Prediction(
            id: id,
            tripId: relationships?.trip?.data?.id ?? "",
            routeId: relationships?.route?.data?.id ?? "",
            stopId: relationships?.stop?.data?.id ?? "",
            arrival: attributes.arrivalTime.flatMap { iso.date(from: $0) },
            departure: attributes.departureTime.flatMap { iso.date(from: $0) },
            scheduleRelationship: Prediction.ScheduleRelationship(rawValue: attributes.scheduleRelationship ?? "SCHEDULED") ?? .scheduled,
            delaySeconds: 0,
            directionId: attributes.directionId ?? 0,
            status: attributes.status
        )
    }
}

// MARK: - Alert Resource

struct AlertResource: Decodable {
    let id: String
    let attributes: Attributes

    struct Attributes: Decodable {
        let effect: String?
        let severity: Int?
        let lifecycle: String?
        let header: String?
        let description: String?
        let url: String?
        let updatedAt: String?
        let createdAt: String?
        let informedEntity: [InformedEntity]?
        let activePeriod: [APeriod]?

        enum CodingKeys: String, CodingKey {
            case effect, severity, lifecycle, header, description, url
            case updatedAt = "updated_at"
            case createdAt = "created_at"
            case informedEntity = "informed_entity"
            case activePeriod = "active_period"
        }
    }

    struct InformedEntity: Decodable {
        let route: String?
        let stop: String?
    }

    struct APeriod: Decodable {
        let start: String?
        let end: String?
    }

    func toServiceAlert() -> ServiceAlert {
        let iso = ISO8601DateFormatter()
        let routeIds = attributes.informedEntity?.compactMap(\.route) ?? []
        let stopIds = attributes.informedEntity?.compactMap(\.stop) ?? []
        let periods = attributes.activePeriod?.map { p in
            ServiceAlert.ActivePeriod(
                start: p.start.flatMap { iso.date(from: $0) },
                end: p.end.flatMap { iso.date(from: $0) }
            )
        } ?? []

        return ServiceAlert(
            id: id,
            effect: ServiceAlert.Effect(rawValue: attributes.effect ?? "") ?? .unknown,
            severity: attributes.severity ?? 0,
            lifecycle: ServiceAlert.Lifecycle(rawValue: attributes.lifecycle ?? "") ?? .ongoing,
            header: attributes.header ?? "",
            description: attributes.description,
            url: attributes.url.flatMap(URL.init(string:)),
            affectedRouteIds: routeIds,
            affectedStopIds: stopIds,
            activePeriods: periods,
            updatedAt: attributes.updatedAt.flatMap { iso.date(from: $0) } ?? Date(),
            createdAt: attributes.createdAt.flatMap { iso.date(from: $0) } ?? Date()
        )
    }
}

// MARK: - Schedule Resource

struct ScheduleResource: Decodable {
    let id: String
    let attributes: Attributes
    let relationships: Relationships?

    struct Attributes: Decodable {
        let arrivalTime: String?
        let departureTime: String?
        let directionId: Int?
        let stopSequence: Int?

        enum CodingKeys: String, CodingKey {
            case arrivalTime = "arrival_time"
            case departureTime = "departure_time"
            case directionId = "direction_id"
            case stopSequence = "stop_sequence"
        }
    }

    struct Relationships: Decodable {
        let route: Relationship?
        let stop: Relationship?
        let trip: Relationship?
    }

    func toSchedule() -> Schedule {
        let iso = ISO8601DateFormatter()
        return Schedule(
            id: id,
            tripId: relationships?.trip?.data?.id ?? "",
            routeId: relationships?.route?.data?.id ?? "",
            stopId: relationships?.stop?.data?.id ?? "",
            arrival: attributes.arrivalTime.flatMap { iso.date(from: $0) },
            departure: attributes.departureTime.flatMap { iso.date(from: $0) },
            directionId: attributes.directionId ?? 0,
            stopSequence: attributes.stopSequence ?? 0
        )
    }
}

// MARK: - Stop Resource

struct StopResource: Decodable {
    let id: String
    let attributes: Attributes
    let relationships: Relationships?

    struct Attributes: Decodable {
        let name: String?
        let latitude: Double?
        let longitude: Double?
        let locationType: Int?

        enum CodingKeys: String, CodingKey {
            case name, latitude, longitude
            case locationType = "location_type"
        }
    }

    struct Relationships: Decodable {
        let parentStation: Relationship?

        enum CodingKeys: String, CodingKey {
            case parentStation = "parent_station"
        }
    }

    func toStop() -> Stop {
        Stop(
            id: id,
            name: attributes.name ?? "",
            latitude: attributes.latitude ?? 0,
            longitude: attributes.longitude ?? 0,
            locationType: Stop.LocationType(rawValue: attributes.locationType ?? 0) ?? .stop,
            parentStationId: relationships?.parentStation?.data?.id
        )
    }
}

// MARK: - Route Resource

struct RouteResource: Decodable {
    let id: String
    let attributes: Attributes

    struct Attributes: Decodable {
        let longName: String?
        let shortName: String?
        let type: Int?
        let color: String?
        let textColor: String?
        let sortOrder: Int?

        enum CodingKeys: String, CodingKey {
            case longName = "long_name"
            case shortName = "short_name"
            case type, color
            case textColor = "text_color"
            case sortOrder = "sort_order"
        }
    }

    func toRouteLine() -> RouteLine {
        RouteLine(
            id: id,
            longName: attributes.longName ?? "",
            shortName: attributes.shortName ?? "",
            type: RouteLine.TransitType(rawValue: attributes.type ?? 1) ?? .heavyRail,
            color: attributes.color ?? "888888",
            textColor: attributes.textColor ?? "FFFFFF",
            sortOrder: attributes.sortOrder ?? 0
        )
    }
}

// MARK: - Shared

struct Relationship: Decodable {
    let data: ResourceIdentifier?
}

struct ResourceIdentifier: Decodable {
    let id: String
    let type: String
}
