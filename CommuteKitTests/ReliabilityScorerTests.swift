import XCTest
@testable import CommuteKit

final class ReliabilityScorerTests: XCTestCase {
    private let scorer = ReliabilityScorer()

    func testPerfectOnTime() {
        let now = Date()
        let predictions = (0..<10).map { i in
            Prediction(
                id: "p-\(i)", tripId: "t-\(i)", routeId: "Red", stopId: "place-davis",
                arrival: nil, departure: now.addingTimeInterval(Double(i) * 600),
                scheduleRelationship: .scheduled, delaySeconds: 0, directionId: 0, status: nil
            )
        }
        let schedules = (0..<10).map { i in
            Schedule(
                id: "s-\(i)", tripId: "t-\(i)", routeId: "Red", stopId: "place-davis",
                arrival: nil, departure: now.addingTimeInterval(Double(i) * 600),
                directionId: 0, stopSequence: 1
            )
        }

        let result = scorer.score(routeId: "Red", predictions: predictions, schedules: schedules)
        XCTAssertEqual(result.onTimePct, 1.0)
        XCTAssertEqual(result.sampleCount, 10)
    }

    func testAllLate() {
        let now = Date()
        let predictions = (0..<5).map { i in
            Prediction(
                id: "p-\(i)", tripId: "t-\(i)", routeId: "Red", stopId: "place-davis",
                arrival: nil, departure: now.addingTimeInterval(Double(i) * 600 + 300),
                scheduleRelationship: .scheduled, delaySeconds: 300, directionId: 0, status: nil
            )
        }
        let schedules = (0..<5).map { i in
            Schedule(
                id: "s-\(i)", tripId: "t-\(i)", routeId: "Red", stopId: "place-davis",
                arrival: nil, departure: now.addingTimeInterval(Double(i) * 600),
                directionId: 0, stopSequence: 1
            )
        }

        let result = scorer.score(routeId: "Red", predictions: predictions, schedules: schedules)
        XCTAssertEqual(result.onTimePct, 0.0)
    }

    func testEmptyDataReturnsDefault() {
        let result = scorer.score(routeId: "Red", predictions: [], schedules: [])
        XCTAssertEqual(result.onTimePct, 1.0)
        XCTAssertEqual(result.sampleCount, 0)
    }
}
