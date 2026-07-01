import Foundation
import os

public actor MBTAClient {
    private let session: URLSession
    private let apiKey: String?
    private let rateLimiter: RateLimiter
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "com.commuteassistant", category: "MBTAClient")

    public init(apiKey: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
        self.rateLimiter = RateLimiter(maxRequestsPerMinute: apiKey != nil ? 1000 : 20)
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Predictions

    public func fetchPredictions(stopIds: [String], routeIds: [String]? = nil) async throws -> [Prediction] {
        guard let url = Endpoints.predictions(stopIds: stopIds, routeIds: routeIds) else {
            throw APIError.invalidURL
        }
        let response: JSONAPIResponse<PredictionResource> = try await request(url: url)
        return response.data.map { $0.toPrediction() }
    }

    // MARK: - Alerts

    public func fetchAlerts(routeIds: [String]? = nil) async throws -> [ServiceAlert] {
        guard let url = Endpoints.alerts(routeIds: routeIds) else {
            throw APIError.invalidURL
        }
        let response: JSONAPIResponse<AlertResource> = try await request(url: url)
        return response.data.map { $0.toServiceAlert() }
    }

    // MARK: - Schedules

    public func fetchSchedules(stopIds: [String], date: Date? = nil) async throws -> [Schedule] {
        guard let url = Endpoints.schedules(stopIds: stopIds, date: date) else {
            throw APIError.invalidURL
        }
        let response: JSONAPIResponse<ScheduleResource> = try await request(url: url)
        return response.data.map { $0.toSchedule() }
    }

    // MARK: - Stops

    public func searchStops(query: String) async throws -> [Stop] {
        guard let url = Endpoints.stops(query: query) else {
            throw APIError.invalidURL
        }
        let response: JSONAPIResponse<StopResource> = try await request(url: url)
        return response.data.map { $0.toStop() }
    }

    public func fetchStops(routeId: String) async throws -> [Stop] {
        guard let url = Endpoints.stops(routeId: routeId) else {
            throw APIError.invalidURL
        }
        let response: JSONAPIResponse<StopResource> = try await request(url: url)
        return response.data.map { $0.toStop() }
    }

    // MARK: - Routes

    public func fetchRoutes() async throws -> [RouteLine] {
        guard let url = Endpoints.routes() else {
            throw APIError.invalidURL
        }
        let response: JSONAPIResponse<RouteResource> = try await request(url: url)
        return response.data.map { $0.toRouteLine() }
    }

    // MARK: - Generic Request

    private func request<T: Decodable>(url: URL) async throws -> T {
        try await rateLimiter.acquire()
        var request = URLRequest(url: url)
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Accept")
        if let apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
}
