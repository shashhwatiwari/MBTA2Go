import SwiftUI
import SwiftData
import BackgroundTasks
import CommuteKit

@main
struct CommuteAssistantApp: App {
    @State private var dependencies = AppDependencies()

    init() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundRefreshService.appRefreshId,
            using: nil
        ) { task in
            BackgroundRefreshService.shared.handleAppRefresh(task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundRefreshService.processingId,
            using: nil
        ) { task in
            BackgroundRefreshService.shared.handleProcessing(task as! BGProcessingTask)
        }

        NotificationService.shared.registerCategories()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
        }
        .modelContainer(SwiftDataStack.shared.container)
    }
}
