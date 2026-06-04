import SwiftUI

// MARK: - Sticky Header
struct StickyHeader: View {
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        HStack {
            // RIVA Wordmark + accent square
            HStack(spacing: 4) {
                Text("RIVA")
                    .font(.rivaWordmark)
                    .foregroundColor(theme.text)
                
                Rectangle()
                    .fill(accent.color)
                    .frame(width: 7, height: 7)
                    .offset(y: -2)
            }
            
            Spacer()
            
            // Search
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.text)
            }
            .padding(.trailing, 8)
            
            // Notifications
            Button(action: {}) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.text)
                    
                    Circle()
                        .fill(accent.color)
                        .frame(width: 7, height: 7)
                        .offset(x: -2, y: 2)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(theme.background)
        .overlay(
            Rectangle()
                .fill(theme.line)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    StickyHeader()
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
        .background(Color.riva.inkBg)
}