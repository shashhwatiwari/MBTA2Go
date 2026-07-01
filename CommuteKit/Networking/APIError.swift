import Foundation

public enum APIError: LocalizedError {
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case rateLimited
    case noData

    public var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL"
        case .httpError(let code): "HTTP error \(code)"
        case .decodingError(let error): "Decoding failed: \(error.localizedDescription)"
        case .networkError(let error): "Network error: \(error.localizedDescription)"
        case .rateLimited: "Rate limit exceeded — try again shortly"
        case .noData: "No data received"
        }
    }
}
