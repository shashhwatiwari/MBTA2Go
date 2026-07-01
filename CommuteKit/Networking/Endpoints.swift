import Foundation

enum Endpoints {
    static let baseURL = "https://api-v3.mbta.com"
    static let gtfsRealtimeBase = "https://cdn.mbta.com/realtime"

    static func predictions(stopIds: [String], routeIds: [String]? = nil) -> URL? {
        var components = URLComponents(string: "\(baseURL)/predictions")
        var items = [
            URLQueryItem(name: "filter[stop]", value: stopIds.joined(separator: ",")),
            URLQueryItem(name: "sort", value: "departure_time"),
            URLQueryItem(name: "include", value: "trip,route"),
            URLQueryItem(name: "page[limit]", value: "20")
        ]
        if let routeIds, !routeIds.isEmpty {
            items.append(URLQueryItem(name: "filter[route]", value: routeIds.joined(separator: ",")))
        }
        components?.queryItems = items
        return components?.url
    }

    static func alerts(routeIds: [String]? = nil) -> URL? {
        var components = URLComponents(string: "\(baseURL)/alerts")
        var items = [
            URLQueryItem(name: "filter[activity]", value: "BOARD,EXIT,RIDE"),
            URLQueryItem(name: "sort", value: "-updated_at")
        ]
        if let routeIds, !routeIds.isEmpty {
            items.append(URLQueryItem(name: "filter[route]", value: routeIds.joined(separator: ",")))
        }
        components?.queryItems = items
        return components?.url
    }

    static func schedules(stopIds: [String], date: Date? = nil) -> URL? {
        var components = URLComponents(string: "\(baseURL)/schedules")
        var items = [
            URLQueryItem(name: "filter[stop]", value: stopIds.joined(separator: ",")),
            URLQueryItem(name: "sort", value: "departure_time"),
            URLQueryItem(name: "page[limit]", value: "20")
        ]
        if let date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            items.append(URLQueryItem(name: "filter[date]", value: formatter.string(from: date)))
        }
        components?.queryItems = items
        return components?.url
    }

    static func stops(routeId: String? = nil, query: String? = nil) -> URL? {
        var components = URLComponents(string: "\(baseURL)/stops")
        var items: [URLQueryItem] = [
            URLQueryItem(name: "filter[location_type]", value: "0,1"),
            URLQueryItem(name: "sort", value: "name")
        ]
        if let routeId {
            items.append(URLQueryItem(name: "filter[route]", value: routeId))
        }
        if let query {
            items.append(URLQueryItem(name: "filter[name]", value: query))
        }
        components?.queryItems = items
        return components?.url
    }

    static func routes() -> URL? {
        var components = URLComponents(string: "\(baseURL)/routes")
        components?.queryItems = [
            URLQueryItem(name: "filter[type]", value: "0,1"),
            URLQueryItem(name: "sort", value: "sort_order")
        ]
        return components?.url
    }

    static var tripUpdates: URL { URL(string: "\(gtfsRealtimeBase)/TripUpdates.pb")! }
    static var vehiclePositions: URL { URL(string: "\(gtfsRealtimeBase)/VehiclePositions.pb")! }
    static var alertsFeed: URL { URL(string: "\(gtfsRealtimeBase)/Alerts.pb")! }
}
