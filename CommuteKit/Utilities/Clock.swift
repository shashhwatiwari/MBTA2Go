import Foundation

public protocol ClockProtocol: Sendable {
    var now: Date { get }
}

public struct SystemClock: ClockProtocol {
    public var now: Date { Date() }
    public init() {}
}

public final class MockClock: ClockProtocol, @unchecked Sendable {
    private var _now: Date
    public var now: Date { _now }

    public init(now: Date = Date()) {
        self._now = now
    }

    public func advance(by interval: TimeInterval) {
        _now = _now.addingTimeInterval(interval)
    }
}
