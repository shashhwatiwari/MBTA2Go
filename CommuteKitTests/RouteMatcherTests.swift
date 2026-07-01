import XCTest
@testable import CommuteKit

final class RouteMatcherTests: XCTestCase {
    private let matcher = RouteMatcher()

    private func makeRoute(
        lineIds: [String] = ["Red"],
        originStopId: String = "place-davis",
        destinationStopId: String = "place-knncl"
    ) -> SavedRoute {
        SavedRoute(
            name: "Test Route",
            originStopId: originStopId,
            destinationStopId: destinationStopId,
            lineIds: lineIds,
            daysOfWeek: [.monday],
            leaveWindowStartHour: 8,
            leaveWindowStartMinute: 0,
            leaveWindowEndHour: 9,
            leaveWindowEndMinute: 0
        )
    }

    private func makeDisruption(
        routeIds: [String] = ["Red"],
        affectedStopIds: [String] = [],
        severity: Disruption.Severity = .moderate
    ) -> Disruption {
        Disruption(
            id: UUID().uuidString,
            routeIds: routeIds,
            affectedStopIds: affectedStopIds,
            severity: severity,
            cause: .delay,
            headline: "Test disruption",
            detail: nil,
            activePeriodStart: Date(),
            activePeriodEnd: Date().addingTimeInterval(3600),
            updatedAt: Date(),
            source: .alertFeed
        )
    }

    func testMatchesByRouteId() {
        let route = makeRoute(lineIds: ["Red"])
        let disruptions = [makeDisruption(routeIds: ["Red"])]
        let result = matcher.disruptions(affecting: route, from: disruptions)
        XCTAssertEqual(result.count, 1)
    }

    func testNoMatchForDifferentRoute() {
        let route = makeRoute(lineIds: ["Red"])
        let disruptions = [makeDisruption(routeIds: ["Orange"])]
        let result = matcher.disruptions(affecting: route, from: disruptions)
        XCTAssertTrue(result.isEmpty)
    }

    func testMatchesByOriginStop() {
        let route = makeRoute(lineIds: ["Blue"], originStopId: "place-davis")
        let disruptions = [makeDisruption(routeIds: ["Orange"], affectedStopIds: ["place-davis"])]
        let result = matcher.disruptions(affecting: route, from: disruptions)
        XCTAssertEqual(result.count, 1)
    }

    func testMatchesByDestinationStop() {
        let route = makeRoute(lineIds: ["Blue"], destinationStopId: "place-knncl")
        let disruptions = [makeDisruption(routeIds: ["Orange"], affectedStopIds: ["place-knncl"])]
        let result = matcher.disruptions(affecting: route, from: disruptions)
        XCTAssertEqual(result.count, 1)
    }

    func testFiltersMultipleDisruptions() {
        let route = makeRoute(lineIds: ["Red", "Green-B"])
        let disruptions = [
            makeDisruption(routeIds: ["Red"]),
            makeDisruption(routeIds: ["Orange"]),
            makeDisruption(routeIds: ["Green-B"]),
        ]
        let result = matcher.disruptions(affecting: route, from: disruptions)
        XCTAssertEqual(result.count, 2)
    }
}
