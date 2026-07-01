import AppIntents

struct ViewNextDepartureIntent: AppIntent {
    static var title: LocalizedStringResource = "View Next Departure"
    static var description: IntentDescription = "Shows the next departure for your commute route"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
