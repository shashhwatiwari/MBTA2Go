import SwiftUI
import CommuteKit

struct AlertsFeedView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: AlertsViewModel?
    @State private var collapsedSections: Set<String> = []

    private let lines = ["Red", "Orange", "Blue", "Green-B", "Green-C", "Green-D", "Green-E"]

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    content(vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Alerts")
            .task {
                let vm = AlertsViewModel(dependencies: dependencies)
                viewModel = vm
                await vm.load()
            }
            .refreshable {
                await viewModel?.load()
            }
        }
    }

    @ViewBuilder
    private func content(_ vm: AlertsViewModel) -> some View {
        switch vm.loadState {
        case .idle, .loading:
            ProgressView()
        case .loaded:
            VStack(spacing: 0) {
                categoryFilterBar(vm)
                lineFilterBar(vm)

                let groups = vm.groupedAlerts
                if groups.isEmpty {
                    ContentUnavailableView("No Alerts", systemImage: "checkmark.circle", description: Text("All clear!"))
                } else {
                    List {
                        ForEach(groups, id: \.category) { group in
                            Section {
                                DisclosureGroup(
                                    isExpanded: Binding(
                                        get: { !collapsedSections.contains(group.category) },
                                        set: { isExpanded in
                                            if isExpanded {
                                                collapsedSections.remove(group.category)
                                            } else {
                                                collapsedSections.insert(group.category)
                                            }
                                        }
                                    )
                                ) {
                                    ForEach(group.alerts) { alert in
                                        alertRow(alert)
                                    }
                                } label: {
                                    HStack {
                                        Text(group.category)
                                            .font(Typography.headline)
                                            .foregroundStyle(Theme.textPrimary)

                                        Spacer()

                                        Text("\(group.alerts.count)")
                                            .font(Typography.caption)
                                            .foregroundStyle(Theme.textSecondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(.secondary.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                }
            }
        case .failed(let error):
            ContentUnavailableView("Error", systemImage: "wifi.exclamationmark", description: Text(error))
        }
    }

    private func categoryFilterBar(_ vm: AlertsViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(
                    label: "All",
                    isSelected: vm.selectedCategory == nil,
                    color: Theme.red
                ) {
                    vm.selectedCategory = nil
                }

                ForEach(vm.categories, id: \.self) { category in
                    chipButton(
                        label: category,
                        isSelected: vm.selectedCategory == category,
                        color: Theme.red
                    ) {
                        vm.selectedCategory = vm.selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func lineFilterBar(_ vm: AlertsViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(
                    label: "All Lines",
                    isSelected: vm.selectedLineFilter == nil,
                    color: Theme.red
                ) {
                    vm.selectedLineFilter = nil
                }

                ForEach(lines, id: \.self) { line in
                    chipButton(
                        label: line,
                        isSelected: vm.selectedLineFilter == line,
                        color: Theme.lineColor(for: line)
                    ) {
                        vm.selectedLineFilter = vm.selectedLineFilter == line ? nil : line
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func chipButton(label: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : .clear)
                .foregroundStyle(isSelected ? .white : Theme.textPrimary)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(color.opacity(0.3), lineWidth: 1))
        }
    }

    private func alertRow(_ alert: ServiceAlert) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: alert.isCurrentlyActive ? "exclamationmark.triangle.fill" : "clock")
                    .foregroundStyle(alert.severity >= 7 ? .red : .orange)

                Text(alert.header)
                    .font(Typography.headline)
            }

            if let description = alert.description {
                Text(description)
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(3)
            }

            HStack {
                ForEach(alert.affectedRouteIds, id: \.self) { routeId in
                    Text(routeId)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.lineColor(for: routeId).opacity(0.15))
                        .foregroundStyle(Theme.lineColor(for: routeId))
                        .clipShape(Capsule())
                }

                Spacer()

                Text(alert.updatedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
