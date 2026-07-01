import SwiftUI

struct SettingsView: View {
    @AppStorage("quietHoursEnabled") private var quietHoursEnabled = false
    @AppStorage("quietHoursStart") private var quietHoursStart = 22
    @AppStorage("quietHoursEnd") private var quietHoursEnd = 7
    @AppStorage("severityThreshold") private var severityThreshold = 1

    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    NavigationLink("Notification Preferences") {
                        NotificationPreferencesView()
                    }
                }

                Section("Quiet Hours") {
                    Toggle("Enable Quiet Hours", isOn: $quietHoursEnabled)
                    if quietHoursEnabled {
                        Stepper("Start: \(quietHoursStart):00", value: $quietHoursStart, in: 0...23)
                        Stepper("End: \(quietHoursEnd):00", value: $quietHoursEnd, in: 0...23)
                    }
                }

                Section("Severity Filter") {
                    Picker("Minimum Severity", selection: $severityThreshold) {
                        Text("All").tag(0)
                        Text("Minor+").tag(1)
                        Text("Moderate+").tag(2)
                        Text("Severe Only").tag(3)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
