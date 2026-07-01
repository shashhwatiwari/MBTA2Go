import Foundation

public struct SuggestedRoute: Identifiable {
    public let id = UUID()
    public let lineIds: [String]
    public let description: String
    public let estimatedDelayMinutes: Int
    public let transferStops: [String]

    public init(lineIds: [String], description: String, estimatedDelayMinutes: Int, transferStops: [String]) {
        self.lineIds = lineIds
        self.description = description
        self.estimatedDelayMinutes = estimatedDelayMinutes
        self.transferStops = transferStops
    }
}

public struct AlternativeRouteSuggester {
    public init() {}

    private let connections: [String: [Connection]] = [
        "Red": [
            Connection(transferStop: "place-pktrm", toLine: "Green-B", description: "Transfer at Park St to Green Line"),
            Connection(transferStop: "place-pktrm", toLine: "Green-C", description: "Transfer at Park St to Green Line"),
            Connection(transferStop: "place-pktrm", toLine: "Green-D", description: "Transfer at Park St to Green Line"),
            Connection(transferStop: "place-pktrm", toLine: "Green-E", description: "Transfer at Park St to Green Line"),
            Connection(transferStop: "place-dwnxg", toLine: "Orange", description: "Transfer at Downtown Crossing to Orange Line"),
        ],
        "Orange": [
            Connection(transferStop: "place-dwnxg", toLine: "Red", description: "Transfer at Downtown Crossing to Red Line"),
            Connection(transferStop: "place-haecl", toLine: "Green-B", description: "Transfer at Haymarket to Green Line"),
            Connection(transferStop: "place-haecl", toLine: "Green-C", description: "Transfer at Haymarket to Green Line"),
            Connection(transferStop: "place-haecl", toLine: "Green-D", description: "Transfer at Haymarket to Green Line"),
            Connection(transferStop: "place-haecl", toLine: "Green-E", description: "Transfer at Haymarket to Green Line"),
            Connection(transferStop: "place-state", toLine: "Blue", description: "Transfer at State to Blue Line"),
        ],
        "Blue": [
            Connection(transferStop: "place-state", toLine: "Orange", description: "Transfer at State to Orange Line"),
            Connection(transferStop: "place-gover", toLine: "Green-B", description: "Transfer at Government Center to Green Line"),
            Connection(transferStop: "place-gover", toLine: "Green-C", description: "Transfer at Government Center to Green Line"),
            Connection(transferStop: "place-gover", toLine: "Green-D", description: "Transfer at Government Center to Green Line"),
            Connection(transferStop: "place-gover", toLine: "Green-E", description: "Transfer at Government Center to Green Line"),
        ],
    ]

    public func suggest(for route: SavedRoute, disruptions: [Disruption]) -> [SuggestedRoute] {
        guard !disruptions.isEmpty else { return [] }

        var suggestions: [SuggestedRoute] = []

        for lineId in route.lineIds {
            guard let lineConnections = connections[lineId] else { continue }

            for conn in lineConnections {
                let isDisrupted = disruptions.contains { d in
                    d.routeIds.contains(conn.toLine)
                }
                guard !isDisrupted else { continue }

                suggestions.append(SuggestedRoute(
                    lineIds: [conn.toLine],
                    description: conn.description,
                    estimatedDelayMinutes: 8,
                    transferStops: [conn.transferStop]
                ))
            }
        }

        return Array(Set(suggestions.map(\.description))
            .prefix(3)
            .compactMap { desc in suggestions.first { $0.description == desc } })
    }

    private struct Connection {
        let transferStop: String
        let toLine: String
        let description: String
    }
}
