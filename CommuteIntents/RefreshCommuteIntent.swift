import AppIntents
import WidgetKit

struct RefreshCommuteIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Commute"
    static var description: IntentDescription = "Refreshes commute data and widgets"

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
