import os

public extension Logger {
    static let networking = Logger(subsystem: "com.commuteassistant", category: "Networking")
    static let background = Logger(subsystem: "com.commuteassistant", category: "Background")
    static let ui = Logger(subsystem: "com.commuteassistant", category: "UI")
}
