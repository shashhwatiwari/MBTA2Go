import SwiftUI

struct StatusDot: View {
    let color: Color
    let isAnimating: Bool

    init(color: Color, isAnimating: Bool = false) {
        self.color = color
        self.isAnimating = isAnimating
    }

    @State private var opacity: Double = 1.0

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .opacity(opacity)
            .animation(isAnimating ? .easeInOut(duration: 1).repeatForever(autoreverses: true) : .default, value: opacity)
            .onAppear {
                if isAnimating { opacity = 0.3 }
            }
    }
}
