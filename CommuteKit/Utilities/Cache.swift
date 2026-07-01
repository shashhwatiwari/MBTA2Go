import Foundation

public actor Cache<Value: Codable> {
    private var memory: [String: Entry] = [:]
    private let ttl: TimeInterval

    private struct Entry {
        let value: Value
        let expiry: Date
        var isExpired: Bool { Date() > expiry }
    }

    public init(ttl: TimeInterval = 300) {
        self.ttl = ttl
    }

    public func get(_ key: String) -> Value? {
        guard let entry = memory[key], !entry.isExpired else {
            memory.removeValue(forKey: key)
            return nil
        }
        return entry.value
    }

    public func set(_ key: String, value: Value) {
        memory[key] = Entry(value: value, expiry: Date().addingTimeInterval(ttl))
    }

    public func invalidate(_ key: String) {
        memory.removeValue(forKey: key)
    }

    public func invalidateAll() {
        memory.removeAll()
    }
}
