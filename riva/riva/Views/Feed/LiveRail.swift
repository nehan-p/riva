import SwiftUI

// MARK: - Live Rail
struct LiveRail: View {
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    // Live user data
    private let users: [(user: RivaUser, isLive: Bool)] = [
        (.jm, true),
        (.mr, true),
        (.sk, false),
        (.jt, true),
        (.al, false),
        (.rp, true),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TRAINING NOW")
                .font(.rivaSectionLabel)
                .foregroundColor(theme.sub)
                .padding(.horizontal, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(users, id: \.user.id) { entry in
                        VStack(spacing: 4) {
                            // Avatar with live ring
                            ZStack {
                                // Ring
                                Circle()
                                    .stroke(
                                        entry.isLive ? accent.color : theme.line,
                                        lineWidth: entry.isLive ? 2.5 : 1.5
                                    )
                                    .frame(width: 50, height: 50)
                                
                                AvatarView(
                                    initials: entry.user.initials,
                                    color: entry.user.avatarColor,
                                    size: 44
                                )
                            }
                            
                            // Live label / dot
                            if entry.isLive {
                                Text("LIVE")
                                    .font(.rivaLiveLabel)
                                    .foregroundColor(accent.color)
                            } else {
                                Circle()
                                    .fill(theme.muted)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(width: 56)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    LiveRail()
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
        .background(Color.riva.inkBg)
}