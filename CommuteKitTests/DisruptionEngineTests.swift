import XCTest
@testable import CommuteKit

final class DisruptionEngineTests: XCTestCase {
    private let engine = DisruptionEngine()

    func testActiveAlertBecomesDisruption() {
        let alert = ServiceAlert(
            id: "alert-1",
            effect: .delay,
            severity: 7,
            lifecycle: .ongoing,
            header: "Red Line delays",
            description: "Delays of up to 10 minutes",
            url: nil,
            affectedRouteIds: ["Red"],
            affectedStopIds: ["place-davis"],
            activePeriods: [
                ServiceAlert.ActivePeriod(
                    start: Date().addingTimeInterval(-3600),
                    end: Date().addingTimeInterval(3600)
                )
            ],
            updatedAt: Date(),
            createdAt: Date()
        )

        let result = engine.merge(alerts: [alert], predictions: [])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.severity, .moderate)
        XCTAssertEqual(result.first?.cause, .delay)
    }

    func testMultipleCanceledTripsCreateComputedDisruption() {
        let predictions = (0..<3).map { i in
            Prediction(
                id: "pred-\(i)",
                tripId: "trip-\(i)",
                routeId: "Red",
                stopId: "place-davis",
                arrival: nil,
                departure: nil,
                scheduleRelationship: .canceled,
                delaySeconds: 0,
                directionId: 0,
                status: nil
            )
        }

        let result = engine.merge(alerts: [], predictions: predictions)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.cause, .serviceChange)
        XCTAssertTrue(result.first?.headline.contains("3 trips canceled") ?? false)
    }

    func testHeavyDelaysCreateComputedDisruption() {
        let predictions = (0..<3).map { i in
            Prediction(
                id: "pred-\(i)",
                tripId: "trip-\(i)",
                routeId: "Orange",
                stopId: "place-state",
                arrival: nil,
                departure: Date().addingTimeInterval(Double(i) * 300),
                scheduleRelationship: .scheduled,
                delaySeconds: 900,
                directionId: 0,
                status: nil
            )
        }

        let result = engine.merge(alerts: [], predictions: predictions)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.cause, .delay)
    }

    func testResultsSortedBySeverity() {
        let alerts = [
            ServiceAlert(
                id: "a1", effect: .delay, severity: 3, lifecycle: .ongoing, header: "Minor",
                description: nil, url: nil, affectedRouteIds: ["Red"], affectedStopIds: [],
                activePeriods: [ServiceAlert.ActivePeriod(start: Date().addingTimeInterval(-3600), end: Date().addingTimeInterval(3600))],
                updatedAt: Date(), createdAt: Date()
            ),
            ServiceAlert(
                id: "a2", effect: .noService, severity: 9, lifecycle: .ongoing, header: "Severe",
                description: nil, url: nil, affectedRouteIds: ["Red"], affectedStopIds: [],
                activePeriods: [ServiceAlert.ActivePeriod(start: Date().addingTimeInterval(-3600), end: Date().addingTimeInterval(3600))],
                updatedAt: Date(), createdAt: Date()
            ),
        ]

        let result = engine.merge(alerts: alerts, predictions: [])
        XCTAssertEqual(result.first?.severity, .severe)
    }

    func testExpiredAlertIsExcluded() {
        let alert = ServiceAlert(
            id: "expired",
            effect: .delay,
            severity: 7,
            lifecycle: .ongoing,
            header: "Past alert",
            description: nil, url: nil,
            affectedRouteIds: ["Red"],
            affectedStopIds: [],
            activePeriods: [
                ServiceAlert.ActivePeriod(
                    start: Date().addingTimeInterval(-7200),
                    end: Date().addingTimeInterval(-3600)
                )
            ],
            updatedAt: Date(), createdAt: Date()
        )

        let result = engine.merge(alerts: [alert], predictions: [])
        XCTAssertTrue(result.isEmpty)
    }
}
