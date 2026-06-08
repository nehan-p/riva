import SwiftUI

// MARK: - Sticky Header
struct StickyHeader: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    @State private var showSignOutDialog = false
    
    var body: some View {
        HStack {
            // User avatar
            if let user = sessionManager.currentUser {
                Button {
                    // Future: navigate to profile
                } label: {
                    AvatarView(
                        initials: user.initials,
                        color: user.avatarColor,
                        size: 34
                    )
                }
            } else {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(theme.muted)
                    .frame(width: 34, height: 34)
            }
            
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
            .padding(.trailing, 8)
            
            // Sign out (gear icon)
            Button {
                showSignOutDialog = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(theme.muted)
            }
            .confirmationDialog("Sign Out", isPresented: $showSignOutDialog) {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await sessionManager.signOut()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
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
        .environmentObject(SessionManager())
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
        .background(Color.riva.inkBg)
}