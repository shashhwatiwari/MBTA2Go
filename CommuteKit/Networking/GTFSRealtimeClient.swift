import Foundation
import os

public actor GTFSRealtimeClient {
    private let session: URLSession
    private let logger = Logger(subsystem: "com.commuteassistant", category: "GTFSRealtime")

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchTripUpdates() async throws -> Data {
        try await fetchFeed(url: Endpoints.tripUpdates)
    }

    public func fetchVehiclePositions() async throws -> Data {
        try await fetchFeed(url: Endpoints.vehiclePositions)
    }

    public func fetchAlerts() async throws -> Data {
        try await fetchFeed(url: Endpoints.alertsFeed)
    }

    private func fetchFeed(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        return data
    }
}
