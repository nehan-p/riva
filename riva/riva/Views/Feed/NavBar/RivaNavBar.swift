import SwiftUI

// MARK: - Nav Bar (Classic plate style)
struct RivaNavBar: View {
    @Binding var selectedTab: RivaTab

    var body: some View {
        ClassicNavBar(selectedTab: $selectedTab)
    }
}

#Preview {
    VStack(spacing: 0) {
        Spacer()
        RivaNavBar(selectedTab: .constant(.feed))
    }
    .environment(\.rivaTheme, .ink)
    .environment(\.rivaAccent, .gold)
    .background(Color.riva.inkBg)
}