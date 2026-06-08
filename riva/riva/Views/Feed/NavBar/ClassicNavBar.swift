import SwiftUI

// MARK: - Classic Nav Bar
struct ClassicNavBar: View {
    @Binding var selectedTab: RivaTab
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        VStack(spacing: 0) {
            // Spacer for the center plate to overlap
            Spacer().frame(height: 0)
            
            // Nav bar
            HStack(spacing: 0) {
                // Left tabs
                ForEach([RivaTab.feed, .find], id: \.self) { tab in
                    navButton(tab)
                }
                
                Spacer()
                
                // Right tabs
                ForEach([RivaTab.activity, .you], id: \.self) { tab in
                    navButton(tab)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(theme.surface)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(theme.line, lineWidth: 1)
            )
            .navShadow(theme: theme)
            .padding(.horizontal, 12)
            
            // Bottom gap
            Color.clear.frame(height: 14)
        }
        .overlay(alignment: .top) {
            // Center "Log Lift" plate — overlaps above the bar
            VStack(spacing: 2) {
                Button(action: { selectedTab = .logLift }) {
                    ZStack {
                        Circle()
                            .fill(accent.color)
                            .frame(width: 52, height: 52)
                            .overlay(
                                Circle()
                                    .stroke(theme.surface, lineWidth: 2)
                            )
                            .plateShadow(theme: theme)
                        
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(accent.onAccentText)
                    }
                }
                .offset(y: -18)
                
                Text("LOG LIFT")
                    .font(.rivaNavLabel)
                    .foregroundColor(accent.color)
                    .offset(y: -12)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func navButton(_ tab: RivaTab) -> some View {
        let isActive = selectedTab == tab
        return Button(action: { selectedTab = tab }) {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isActive ? .bold : .regular))
                    .foregroundColor(isActive ? accent.color : theme.muted)
                
                Text(tab.shortLabel)
                    .font(.rivaNavLabel)
                    .foregroundColor(isActive ? theme.text : theme.muted)
            }
            .frame(width: 56, height: 44)
        }
    }
}

#Preview {
    ClassicNavBar(selectedTab: .constant(.feed))
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
        .background(Color.riva.inkBg)
}