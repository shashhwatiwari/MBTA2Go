import SwiftUI
import SwiftData
import CommuteKit

struct RouteListView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @Query private var routes: [SavedRoute]
    @State private var showingEditor = false

    var body: some View {
        NavigationStack {
            Group {
                if routes.isEmpty {
                    ContentUnavailableView(
                        "No Routes",
                        systemImage: "map",
                        description: Text("Add a commute route to get started")
                    )
                } else {
                    List {
                        ForEach(routes) { route in
                            NavigationLink(value: route) {
                                routeRow(route)
                            }
                        }
                        .onDelete(perform: deleteRoutes)
                    }
                }
            }
            .navigationTitle("Routes")
            .navigationDestination(for: SavedRoute.self) { route in
                RouteDetailView(route: route)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingEditor = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                RouteEditorView()
                    .environment(dependencies)
            }
        }
    }

    private func routeRow(_ route: SavedRoute) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(route.name)
                    .font(Typography.headline)

                let origin = route.originStopName.isEmpty ? route.originStopId : route.originStopName
                let dest = route.destinationStopName.isEmpty ? route.destinationStopId : route.destinationStopName
                Text("\(origin) → \(dest)")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            HStack(spacing: 4) {
                ForEach(route.lineIds, id: \.self) { lineId in
                    Circle()
                        .fill(Theme.lineColor(for: lineId))
                        .frame(width: 12, height: 12)
                }
            }

            if !route.isActive {
                Image(systemName: "moon.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
    }

    private func deleteRoutes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(routes[index])
        }
    }
}
