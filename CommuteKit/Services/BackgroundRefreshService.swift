import Foundation
import BackgroundTasks
import SwiftData
import os

public final class BackgroundRefreshService: @unchecked Sendable {
    public static let shared = BackgroundRefreshService()

    public static let appRefreshId = "com.commuteassistant.refresh"
    public static let processingId = "com.commuteassistant.process"

    private let logger = Logger(subsystem: "com.commuteassistant", category: "BackgroundRefresh")

    private init() {}

    public func handleAppRefresh(_ task: BGAppRefreshTask) {
        let refreshTask = Task {
            do {
                try await runRefreshCycle()
                task.setTaskCompleted(success: true)
            } catch {
                logger.error("Refresh failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            refreshTask.cancel()
        }

        scheduleNextRefresh()
    }

    public func handleProcessing(_ task: BGProcessingTask) {
        let processingTask = Task {
            do {
                try await runReliabilityScoring()
                task.setTaskCompleted(success: true)
            } catch {
                logger.error("Processing failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            processingTask.cancel()
        }
    }

    public func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.appRefreshId)
        request.earliestBeginDate = Date().addingTimeInterval(15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Scheduled next refresh")
        } catch {
            logger.error("Failed to schedule refresh: \(error)")
        }
    }

    public func scheduleProcessing() {
        let request = BGProcessingTaskRequest(identifier: Self.processingId)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.error("Failed to schedule processing: \(error)")
        }
    }

    private func runRefreshCycle() async throws {
        let client = MBTAClient(apiKey: Secrets.mbtaAPIKey)
        let disruptionEngine = DisruptionEngine()
        let routeMatcher = RouteMatcher()

        let container = SwiftDataStack.shared.container
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<SavedRoute>(predicate: #Predicate { $0.isActive })
        let routes = try context.fetch(descriptor)

        for route in routes {
            guard isInCommuteWindow(route) else { continue }

            async let predictions = client.fetchPredictions(
                stopIds: [route.originStopId],
                routeIds: route.lineIds
            )
            async let alerts = client.fetchAlerts(routeIds: route.lineIds)

            let (preds, alts) = try await (predictions, alerts)
            let disruptions = disruptionEngine.merge(alerts: alts, predictions: preds)
            let relevant = routeMatcher.disruptions(affecting: route, from: disruptions)

            for disruption in relevant where disruption.severity >= .moderate {
                let hash = disruptionHash(disruption)
                if route.lastNotifiedDisruptionHash != hash {
                    await NotificationService.shared.scheduleDisruptionNotification(
                        disruption: disruption,
                        routeName: route.name
                    )
                    route.lastNotifiedDisruptionHash = hash
                }
            }
        }

        try context.save()
    }

    private func runReliabilityScoring() async throws {
        logger.info("Running reliability scoring")
    }

    private func isInCommuteWindow(_ route: SavedRoute) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)

        guard route.daysOfWeek.contains(where: { $0.rawValue == weekday }) else { return false }

        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        let windowStart = route.leaveWindowStartHour * 60 + route.leaveWindowStartMinute - route.notifyLeadMinutes
        let windowEnd = route.leaveWindowEndHour * 60 + route.leaveWindowEndMinute + 30

        return currentMinutes >= windowStart && currentMinutes <= windowEnd
    }

    private func disruptionHash(_ disruption: Disruption) -> String {
        let bucketedTime = Int(disruption.updatedAt.timeIntervalSince1970 / 300) * 300
        let input = "\(disruption.id)\(bucketedTime)"
        var hash: UInt64 = 5381
        for byte in input.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return String(hash, radix: 16)
    }
}
