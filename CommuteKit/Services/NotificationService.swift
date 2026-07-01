import Foundation
import UserNotifications
import os

public final class NotificationService: @unchecked Sendable {
    public static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.commuteassistant", category: "Notifications")

    public static let disruptionCategoryId = "COMMUTE_DISRUPTION"

    private init() {}

    public func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
    }

    public func registerCategories() {
        let viewAlternatives = UNNotificationAction(identifier: "VIEW_ALTERNATIVES", title: "View Alternatives")
        let snooze = UNNotificationAction(identifier: "SNOOZE_10", title: "Snooze 10 min")
        let muteRoute = UNNotificationAction(identifier: "MUTE_ROUTE_TODAY", title: "Mute Route Today", options: .destructive)

        let category = UNNotificationCategory(
            identifier: Self.disruptionCategoryId,
            actions: [viewAlternatives, snooze, muteRoute],
            intentIdentifiers: []
        )
        center.setNotificationCategories([category])
    }

    public func scheduleDisruptionNotification(disruption: Disruption, routeName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "\(routeName) — \(disruption.severity.label) Disruption"
        content.body = disruption.headline
        if let detail = disruption.detail {
            content.subtitle = String(detail.prefix(100))
        }
        content.categoryIdentifier = Self.disruptionCategoryId
        content.sound = .default

        switch disruption.severity {
        case .severe, .moderate:
            content.interruptionLevel = .timeSensitive
        case .minor:
            content.interruptionLevel = .active
        case .info:
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "disruption-\(disruption.id)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            logger.info("Scheduled notification for disruption \(disruption.id)")
        } catch {
            logger.error("Failed to schedule notification: \(error)")
        }
    }

    public func removeDeliveredNotifications(for routeId: String) {
        center.getDeliveredNotifications { notifications in
            let ids = notifications
                .filter { $0.request.identifier.contains(routeId) }
                .map(\.request.identifier)
            self.center.removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
}
