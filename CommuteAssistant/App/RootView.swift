import SwiftUI
import CommuteKit

struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                TabView {
                    TodayView()
                        .tabItem { Label("Today", systemImage: "clock.fill") }
                    RouteListView()
                        .tabItem { Label("Routes", systemImage: "map.fill") }
                    AlertsFeedView()
                        .tabItem { Label("Alerts", systemImage: "exclamationmark.triangle.fill") }
                    SettingsView()
                        .tabItem { Label("Settings", systemImage: "gear") }
                }
                .tint(Theme.red)
            } else {
                OnboardingFlow(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                BackgroundRefreshService.shared.scheduleNextRefresh()
            }
        }
    }
}
