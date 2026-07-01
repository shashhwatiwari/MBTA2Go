import SwiftUI
import CommuteKit

struct PermissionsCoordinator: View {
    @Environment(AppDependencies.self) private var dependencies
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "location.fill")
                .font(.system(size: 60))
                .foregroundStyle(Theme.blue)
            Text("Location Access")
                .font(Typography.title)
            Text("Helps detect when you're near a stop and provides relevant commute info")
                .font(Typography.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button("Allow Location") {
                dependencies.locationService.requestWhenInUseAuthorization()
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.red)

            Spacer()

            Button("Skip") {
                onComplete()
            }
            .foregroundStyle(Theme.textSecondary)
        }
        .padding()
    }
}
