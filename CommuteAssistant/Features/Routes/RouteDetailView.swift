import SwiftUI
import CommuteKit

struct RouteDetailView: View {
    let route: SavedRoute
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: RouteViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(route.name)
        .task {
            let vm = RouteViewModel(dependencies: dependencies)
            viewModel = vm
            await vm.loadDetail(for: route)
        }
    }

    @ViewBuilder
    private func content(_ vm: RouteViewModel) -> some View {
        switch vm.loadState {
        case .idle, .loading:
            ProgressView()
        case .loaded:
            ScrollView {
                VStack(spacing: 16) {
                    if let reliability = vm.reliability {
                        ReliabilityChip(score: reliability)
                    }

                    if !vm.disruptions.isEmpty {
                        ForEach(vm.disruptions) { disruption in
                            DisruptionBanner(disruption: disruption)
                        }
                    }

                    if !vm.predictions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Upcoming Departures")
                                .font(Typography.headline)
                            ForEach(vm.predictions.prefix(5)) { pred in
                                DepartureCard(prediction: pred)
                            }
                        }
                    }

                    if !vm.alternatives.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alternatives")
                                .font(Typography.headline)
                            ForEach(vm.alternatives) { alt in
                                Card {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(alt.description)
                                            .font(Typography.body)
                                        Text("+~\(alt.estimatedDelayMinutes) min")
                                            .font(Typography.caption)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        case .failed(let error):
            ContentUnavailableView("Error", systemImage: "wifi.exclamationmark", description: Text(error))
        }
    }
}
