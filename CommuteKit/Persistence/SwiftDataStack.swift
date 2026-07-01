import Foundation
import SwiftData

public final class SwiftDataStack: @unchecked Sendable {
    public static let shared = SwiftDataStack()

    public let container: ModelContainer

    private init() {
        do {
            container = try ModelContainer(for: SavedRoute.self)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }
}
