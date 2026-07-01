import Foundation

public enum LoadState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case failed(String)

    public static func == (lhs: LoadState, rhs: LoadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded): return true
        case (.failed(let a), .failed(let b)): return a == b
        default: return false
        }
    }
}
