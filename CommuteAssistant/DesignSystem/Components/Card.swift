import SwiftUI

struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
