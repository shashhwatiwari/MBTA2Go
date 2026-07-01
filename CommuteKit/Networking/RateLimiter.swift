import Foundation

actor RateLimiter {
    private let maxTokens: Int
    private let refillInterval: TimeInterval
    private var tokens: Int
    private var lastRefill: Date

    init(maxRequestsPerMinute: Int) {
        self.maxTokens = maxRequestsPerMinute
        self.refillInterval = 60.0
        self.tokens = maxRequestsPerMinute
        self.lastRefill = Date()
    }

    func acquire() async throws {
        refillTokens()
        guard tokens > 0 else {
            throw APIError.rateLimited
        }
        tokens -= 1
    }

    private func refillTokens() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastRefill)
        if elapsed >= refillInterval {
            tokens = maxTokens
            lastRefill = now
        }
    }
}
