import AppIntents

struct CommuteShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ViewNextDepartureIntent(),
            phrases: [
                "Show my next \(.applicationName) departure",
                "When is my next train in \(.applicationName)",
                "Check \(.applicationName)"
            ],
            shortTitle: "Next Departure",
            systemImageName: "tram.fill"
        )

        AppShortcut(
            intent: RefreshCommuteIntent(),
            phrases: [
                "Refresh \(.applicationName)",
                "Update \(.applicationName) data"
            ],
            shortTitle: "Refresh",
            systemImageName: "arrow.clockwise"
        )
    }
}
