import SwiftUI

// MARK: - PR Badge
struct PRBadge: View {
    @Environment(\.rivaTheme) private var theme
    @State private var hasAppeared = false

    var body: some View {
        HStack(spacing: 6) {
            Text("🏆")
                .font(.system(size: 15))
            Text("New PR!")
                .font(.interSemiBold(13))
                .foregroundColor(RivaAccent.gold.onAccentText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.riva.gold)
        .clipShape(Capsule())
        .rivaShadow(color: theme.hardShadow, x: 4, y: 4)
        .scaleEffect(hasAppeared ? 1 : 0.5)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: hasAppeared)
        .onAppear { hasAppeared = true }
    }
}
