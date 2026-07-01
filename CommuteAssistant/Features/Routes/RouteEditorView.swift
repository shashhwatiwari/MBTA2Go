import SwiftUI
import SwiftData
import CommuteKit

struct RouteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedOrigin: Stop?
    @State private var selectedDestination: Stop?
    @State private var selectedLines: Set<String> = []
    @State private var selectedDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    @State private var windowStart = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @State private var windowEnd = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var leadMinutes = 15

    @State private var allStops: [Stop] = []
    @State private var availableLines: [RouteLine] = []
    @State private var originSearch = ""
    @State private var destSearch = ""
    @State private var isLoadingStops = true

    private let mbtaClient = MBTAClient(apiKey: Secrets.mbtaAPIKey)

    var body: some View {
        NavigationStack {
            Form {
                Section("Route Name") {
                    TextField("Morning Commute", text: $name)
                }

                Section("Origin Stop") {
                    stopSection(
                        selection: $selectedOrigin,
                        search: $originSearch
                    )
                }

                Section("Destination Stop") {
                    stopSection(
                        selection: $selectedDestination,
                        search: $destSearch
                    )
                }

                Section {
                    lineSelector
                } header: {
                    Text("Lines")
                } footer: {
                    Text("Select all lines your commute uses")
                }

                Section {
                    dayPresets
                    daySelector
                } header: {
                    Text("Schedule")
                } footer: {
                    Text("Tap individual days for a custom schedule")
                }

                Section {
                    DatePicker("Earliest departure", selection: $windowStart, displayedComponents: .hourAndMinute)
                    DatePicker("Latest departure", selection: $windowEnd, displayedComponents: .hourAndMinute)
                    Stepper("Notify \(leadMinutes) min before", value: $leadMinutes, in: 5...60, step: 5)
                } footer: {
                    Text("We'll check for departures in this time window")
                }
            }
            .navigationTitle("New Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
            .task {
                await loadData()
            }
        }
    }

    // MARK: - Stop Picker

    @ViewBuilder
    private func stopSection(selection: Binding<Stop?>, search: Binding<String>) -> some View {
        if isLoadingStops {
            HStack {
                ProgressView()
                Text("Loading stops...")
                    .foregroundStyle(.secondary)
            }
        } else if let stop = selection.wrappedValue {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stop.name)
                        .font(.body)
                    Text(stop.id)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Change") {
                    selection.wrappedValue = nil
                    search.wrappedValue = ""
                }
                .font(.caption)
            }
        } else {
            TextField("Search stops...", text: search)
                .autocorrectionDisabled()

            let filtered = filteredStops(query: search.wrappedValue)
            if !search.wrappedValue.isEmpty {
                ForEach(filtered.prefix(8)) { stop in
                    Button {
                        selection.wrappedValue = stop
                        search.wrappedValue = stop.name
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stop.name)
                                .foregroundStyle(Theme.textPrimary)
                            Text(stop.id)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if filtered.isEmpty {
                    Text("No stops found")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func filteredStops(query: String) -> [Stop] {
        guard !query.isEmpty else { return [] }
        let lowered = query.lowercased()
        return allStops.filter { $0.name.lowercased().contains(lowered) }
    }

    // MARK: - Line Selector

    private var lineSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(availableLines, id: \.id) { line in
                    Button {
                        if selectedLines.contains(line.id) {
                            selectedLines.remove(line.id)
                        } else {
                            selectedLines.insert(line.id)
                        }
                    } label: {
                        Text(line.longName)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedLines.contains(line.id) ? line.displayColor : .clear)
                            .foregroundStyle(selectedLines.contains(line.id) ? .white : Theme.textPrimary)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(line.displayColor, lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: - Day Selector

    private var dayPresets: some View {
        HStack(spacing: 12) {
            Button("Weekdays") {
                selectedDays = [.monday, .tuesday, .wednesday, .thursday, .friday]
            }
            .buttonStyle(.bordered)
            .tint(selectedDays == [.monday, .tuesday, .wednesday, .thursday, .friday] ? Theme.red : .secondary)

            Button("Weekends") {
                selectedDays = [.saturday, .sunday]
            }
            .buttonStyle(.bordered)
            .tint(selectedDays == [.saturday, .sunday] ? Theme.red : .secondary)

            Button("Every Day") {
                selectedDays = Set(Weekday.allCases)
            }
            .buttonStyle(.bordered)
            .tint(selectedDays == Set(Weekday.allCases) ? Theme.red : .secondary)
        }
        .font(.caption)
    }

    private var daySelector: some View {
        HStack {
            ForEach(Weekday.allCases) { day in
                Button {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                } label: {
                    Text(String(day.shortName.prefix(1)))
                        .font(.caption.weight(.semibold))
                        .frame(width: 32, height: 32)
                        .background(selectedDays.contains(day) ? Theme.red : .clear)
                        .foregroundStyle(selectedDays.contains(day) ? .white : Theme.textPrimary)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Theme.red.opacity(0.3), lineWidth: 1))
                }
            }
        }
    }

    // MARK: - Validation & Save

    private var isValid: Bool {
        !name.isEmpty && selectedOrigin != nil && selectedDestination != nil && !selectedLines.isEmpty && !selectedDays.isEmpty
    }

    private func save() {
        guard let origin = selectedOrigin, let dest = selectedDestination else { return }
        let calendar = Calendar.current

        let route = SavedRoute(
            name: name,
            originStopId: origin.id,
            originStopName: origin.name,
            destinationStopId: dest.id,
            destinationStopName: dest.name,
            lineIds: Array(selectedLines),
            daysOfWeek: Array(selectedDays),
            leaveWindowStartHour: calendar.component(.hour, from: windowStart),
            leaveWindowStartMinute: calendar.component(.minute, from: windowStart),
            leaveWindowEndHour: calendar.component(.hour, from: windowEnd),
            leaveWindowEndMinute: calendar.component(.minute, from: windowEnd),
            notifyLeadMinutes: leadMinutes
        )

        modelContext.insert(route)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save route: \(error)")
        }
        dismiss()
    }

    // MARK: - Data Loading

    private func loadData() async {
        isLoadingStops = true
        async let stopsTask = loadAllStops()
        async let linesTask: () = loadLines()
        let (stops, _) = await (stopsTask, linesTask)
        var seen = Set<String>()
        allStops = stops.filter { seen.insert($0.id).inserted }.sorted { $0.name < $1.name }
        isLoadingStops = false
    }

    private func loadAllStops() async -> [Stop] {
        do {
            return try await mbtaClient.fetchStops(routeId: "Red")
                + (try await mbtaClient.fetchStops(routeId: "Orange"))
                + (try await mbtaClient.fetchStops(routeId: "Blue"))
                + (try await mbtaClient.fetchStops(routeId: "Green-B"))
                + (try await mbtaClient.fetchStops(routeId: "Green-C"))
                + (try await mbtaClient.fetchStops(routeId: "Green-D"))
                + (try await mbtaClient.fetchStops(routeId: "Green-E"))
                + (try await mbtaClient.fetchStops(routeId: "Mattapan"))
        } catch {
            print("Failed to load stops: \(error)")
            return []
        }
    }

    private func loadLines() async {
        do {
            availableLines = try await mbtaClient.fetchRoutes()
        } catch {
            availableLines = []
        }
    }
}
