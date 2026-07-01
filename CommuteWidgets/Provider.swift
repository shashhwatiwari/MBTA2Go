import WidgetKit
import SwiftUI
import SwiftData
import CommuteKit

struct DepartureEntry: TimelineEntry {
    let date: Date
    let routeName: String
    let lineName: String
    let lineColor: String
    let minutesUntilDeparture: Int?
    let followingMinutes: Int?
    let stopName: String
    let isPlaceholder: Bool

    static let placeholder = DepartureEntry(
        date: Date(),
        routeName: "Morning Commute",
        lineName: "Red",
        lineColor: "DA291C",
        minutesUntilDeparture: 5,
        followingMinutes: 12,
        stopName: "Davis",
        isPlaceholder: true
    )
}

struct DepartureProvider: TimelineProvider {
    func placeholder(in context: Context) -> DepartureEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (DepartureEntry) -> Void) {
        completion(.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DepartureEntry>) -> Void) {
        Task {
            do {
                let container = SwiftDataStack.shared.container
                let context = ModelContext(container)
                let descriptor = FetchDescriptor<SavedRoute>(predicate: #Predicate { $0.isActive })
                let routes = try context.fetch(descriptor)

                guard let route = routes.first else {
                    let entry = DepartureEntry(
                        date: Date(),
                        routeName: "No Route",
                        lineName: "",
                        lineColor: "888888",
                        minutesUntilDeparture: nil,
                        followingMinutes: nil,
                        stopName: "",
                        isPlaceholder: false
                    )
                    completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900))))
                    return
                }

                let client = MBTAClient(apiKey: Secrets.mbtaAPIKey)
                let predictions = try await client.fetchPredictions(
                    stopIds: [route.originStopId],
                    routeIds: route.lineIds
                )

                let first = predictions.first
                let second = predictions.dropFirst().first

                let entry = DepartureEntry(
                    date: Date(),
                    routeName: route.name,
                    lineName: route.lineIds.first ?? "",
                    lineColor: lineColorHex(route.lineIds.first ?? ""),
                    minutesUntilDeparture: first?.minutesUntilDeparture,
                    followingMinutes: second?.minutesUntilDeparture,
                    stopName: route.originStopId,
                    isPlaceholder: false
                )

                let refreshDate = Date().addingTimeInterval(120)
                completion(Timeline(entries: [entry], policy: .after(refreshDate)))
            } catch {
                completion(Timeline(entries: [.placeholder], policy: .after(Date().addingTimeInterval(300))))
            }
        }
    }

    private func lineColorHex(_ lineId: String) -> String {
        switch lineId {
        case "Red": "DA291C"
        case "Orange": "ED8B00"
        case "Blue": "003DA5"
        case let id where id.hasPrefix("Green"): "00843D"
        default: "7C878E"
        }
    }
}
