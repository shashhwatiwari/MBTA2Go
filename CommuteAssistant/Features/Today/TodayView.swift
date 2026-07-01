import SwiftUI
import SwiftData
import CommuteKit

struct TodayView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Query(filter: #Predicate<SavedRoute> { $0.isActive }) private var routes: [SavedRoute]
    @State private var viewModel: TodayViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    content(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Today")
            .task {
                let vm = TodayViewModel(dependencies: dependencies)
                viewModel = vm
                await vm.load(routes: routes)
            }
            .refreshable {
                await viewModel?.refresh(routes: routes)
            }
        }
    }

    @ViewBuilder
    private func content(_ vm: TodayViewModel) -> some View {
        switch vm.loadState {
        case .idle, .loading:
            ProgressView()
        case .loaded:
            loadedContent(vm)
        case .failed(let error):
            ContentUnavailableView("Unable to Load", systemImage: "wifi.exclamationmark", description: Text(error))
        }
    }

    private func loadedContent(_ vm: TodayViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if let route = vm.activeRoute {
                    routeHeader(route, vm: vm)
                }

                if !vm.activeDisruptions.isEmpty {
                    ForEach(vm.activeDisruptions) { disruption in
                        DisruptionBanner(disruption: disruption)
                    }
                }

                if let leaveBy = vm.leaveByRecommendation {
                    leaveByCard(leaveBy)
                }

                if !vm.nextDepartures.isEmpty {
                    departuresSection(vm)
                }

                if let reliability = vm.reliability {
                    ReliabilityChip(score: reliability)
                }
            }
            .padding()
        }
    }

    private func routeHeader(_ route: SavedRoute, vm: TodayViewModel) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                Text(route.name)
                    .font(Typography.title)

                HStack {
                    ForEach(route.lineIds, id: \.self) { lineId in
                        Text(lineId)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.lineColor(for: lineId))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func leaveByCard(_ leaveBy: Date) -> some View {
        Card {
            VStack(spacing: 8) {
                Text("Leave By")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textSecondary)
                Text(leaveBy, style: .time)
                    .font(Typography.countdown)
                    .foregroundStyle(Theme.red)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func departuresSection(_ vm: TodayViewModel) -> some View {
        let grouped = Dictionary(grouping: vm.nextDepartures, by: { $0.routeId })
        let sortedGroups = grouped.sorted { lhs, rhs in
            let lhsFirst = lhs.value.first?.departure ?? .distantFuture
            let rhsFirst = rhs.value.first?.departure ?? .distantFuture
            return lhsFirst < rhsFirst
        }

        return VStack(alignment: .leading, spacing: 12) {
            Text("Next Departures")
                .font(Typography.headline)

            ForEach(sortedGroups, id: \.key) { routeId, departures in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Theme.lineColor(for: routeId))
                            .frame(width: 10, height: 10)
                        Text(routeId)
                            .font(Typography.caption.weight(.semibold))
                            .foregroundStyle(Theme.lineColor(for: routeId))
                    }

                    ForEach(Array(departures.prefix(3))) { prediction in
                        DepartureCard(prediction: prediction)
                    }
                }
            }
        }
    }
}
