import XCTest
@testable import CommuteKit

final class CommuteWindowResolverTests: XCTestCase {
    private let resolver = CommuteWindowResolver()

    private func makeRoute(
        startHour: Int = 8, startMinute: Int = 0,
        endHour: Int = 9, endMinute: Int = 0,
        leadMinutes: Int = 15,
        daysOfWeek: [Weekday] = Weekday.allCases
    ) -> SavedRoute {
        SavedRoute(
            name: "Test",
            originStopId: "place-davis",
            destinationStopId: "place-knncl",
            lineIds: ["Red"],
            daysOfWeek: daysOfWeek,
            leaveWindowStartHour: startHour,
            leaveWindowStartMinute: startMinute,
            leaveWindowEndHour: endHour,
            leaveWindowEndMinute: endMinute,
            notifyLeadMinutes: leadMinutes
        )
    }

    func testLeaveByWithNoReliability() {
        let route = makeRoute()
        let departure = Date().addingTimeInterval(1200) // 20 min from now
        let result = resolver.leaveByDate(for: route, nextDeparture: departure, reliability: nil)

        XCTAssertNotNil(result)
        // 5 min walk + 2 min buffer = 7 min before departure
        let expectedInterval = 7.0 * 60
        XCTAssertEqual(result!.timeIntervalSince1970, departure.timeIntervalSince1970 - expectedInterval, accuracy: 1)
    }

    func testLeaveByWithReliabilityPadding() {
        let route = makeRoute()
        let departure = Date().addingTimeInterval(1200)
        let reliability = ReliabilityScore(
            routeId: "Red",
            windowStart: Date().addingTimeInterval(-86400 * 14),
            windowEnd: Date(),
            onTimePct: 0.7,
            p50DelaySec: 120,
            p90DelaySec: 480,
            sampleCount: 100
        )

        let result = resolver.leaveByDate(for: route, nextDeparture: departure, reliability: reliability)
        XCTAssertNotNil(result)
        // 5 walk + 2 buffer + 8 (480s p90) = 15 min
        let expectedInterval = 15.0 * 60
        XCTAssertEqual(result!.timeIntervalSince1970, departure.timeIntervalSince1970 - expectedInterval, accuracy: 1)
    }

    func testLeaveByWithNilDeparture() {
        let route = makeRoute()
        let result = resolver.leaveByDate(for: route, nextDeparture: nil, reliability: nil)
        XCTAssertNil(result)
    }

    func testIsWithinCommuteWindow() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)

        let route = makeRoute(
            startHour: max(0, hour - 1),
            endHour: min(23, hour + 1)
        )

        XCTAssertTrue(resolver.isWithinCommuteWindow(route, now: now))
    }

    func testIsOutsideCommuteWindow() {
        let route = makeRoute(startHour: 2, endHour: 3)
        let calendar = Calendar.current
        let noon = calendar.date(from: DateComponents(hour: 12, minute: 0))!

        XCTAssertFalse(resolver.isWithinCommuteWindow(route, now: noon))
    }
}
