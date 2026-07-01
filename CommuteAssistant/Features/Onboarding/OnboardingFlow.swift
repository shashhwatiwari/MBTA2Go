import SwiftUI
import CommuteKit

struct OnboardingFlow: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentStep = 0

    var body: some View {
        TabView(selection: $currentStep) {
            welcomeStep.tag(0)
            notificationStep.tag(1)
            locationStep.tag(2)
            completeStep.tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "tram.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.red)
            Text("CommuteAssistant")
                .font(Typography.largeTitle)
            Text("Your intelligent MBTA commute companion")
                .font(Typography.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            nextButton
        }
        .padding()
    }

    private var notificationStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundStyle(Theme.orange)
            Text("Stay Informed")
                .font(Typography.title)
            Text("Get time-sensitive alerts when disruptions affect your commute")
                .font(Typography.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button("Enable Notifications") {
                Task {
                    _ = try? await NotificationService.shared.requestAuthorization()
                    currentStep = 2
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.red)

            Spacer()
            skipButton
        }
        .padding()
    }

    private var locationStep: some View {
        PermissionsCoordinator {
            currentStep = 3
        }
    }

    private var completeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            Text("You're All Set!")
                .font(Typography.title)
            Text("Add your first commute route to get started")
                .font(Typography.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()

            Button("Get Started") {
                hasCompletedOnboarding = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.red)
            .controlSize(.large)
        }
        .padding()
    }

    private var nextButton: some View {
        Button("Continue") { currentStep += 1 }
            .buttonStyle(.borderedProminent)
            .tint(Theme.red)
            .controlSize(.large)
    }

    private var skipButton: some View {
        Button("Skip") { currentStep += 1 }
            .foregroundStyle(Theme.textSecondary)
    }
}
