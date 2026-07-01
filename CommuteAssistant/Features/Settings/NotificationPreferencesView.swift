import SwiftUI

struct NotificationPreferencesView: View {
    @AppStorage("notifyDelays") private var notifyDelays = true
    @AppStorage("notifyServiceChanges") private var notifyServiceChanges = true
    @AppStorage("notifyClosures") private var notifyClosures = true
    @AppStorage("notifyMaintenance") private var notifyMaintenance = false

    var body: some View {
        Form {
            Section("Alert Types") {
                Toggle("Delays", isOn: $notifyDelays)
                Toggle("Service Changes", isOn: $notifyServiceChanges)
                Toggle("Stop/Station Closures", isOn: $notifyClosures)
                Toggle("Planned Maintenance", isOn: $notifyMaintenance)
            }

            Section(footer: Text("Time-sensitive notifications are used for moderate and severe disruptions to ensure you see them promptly.")) {
                Text("Time-sensitive alerts are enabled for moderate and severe disruptions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}
