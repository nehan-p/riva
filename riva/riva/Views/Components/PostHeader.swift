import SwiftUI

// MARK: - Post Header
struct PostHeader: View {
    let post: Post
    @Environment(\.rivaTheme) private var theme
    
    var body: some View {
        HStack(spacing: 10) {
            // Avatar
            AvatarView(initials: post.author.initials, color: post.author.avatarColor, size: 40)
            
            // Name + Handle/Time
            VStack(alignment: .leading, spacing: 1) {
                Text(post.author.name.uppercased())
                    .font(.rivaPostAuthor)
                    .foregroundColor(theme.text)
                    .lineLimit(1)
                
                Text(post.handleTime)
                    .font(.rivaHandleTime)
                    .foregroundColor(theme.muted)
            }
            
            Spacer(minLength: 8)
            
            // Tag pill
            TagPill(label: post.tag)
            
            // Overflow button
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.muted)
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let initials: String
    let color: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
            
            Text(initials)
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Tag Pill
struct TagPill: View {
    let label: String
    @Environment(\.rivaTheme) private var theme
    
    var body: some View {
        Text(label)
            .font(.rivaTagPill)
            .foregroundColor(theme.sub)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(theme.chip)
            .cornerRadius(7)
            .textCase(.uppercase)
    }
}

// MARK: - Face Pile
struct FacePile: View {
    let reactorInitials: [String]
    let totalReactors: Int
    @Environment(\.rivaTheme) private var theme
    
    private let avatarColors: [String: Color] = [
        "MR": Color.riva.avatarMR,
        "SK": Color.riva.avatarSK,
        "JT": Color.riva.avatarJT,
        "AL": Color.riva.avatarAL,
        "RP": Color.riva.avatarRP,
        "MP": Color.riva.avatarMP,
        "JM": Color.riva.avatarJM,
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Overlapping avatars
            ZStack {
                ForEach(Array(reactorInitials.prefix(3).enumerated()), id: \.offset) { index, initials in
                    Circle()
                        .fill(avatarColors[initials] ?? .gray)
                        .frame(width: 21, height: 21)
                        .overlay(
                            Text(initials)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(theme.surface, lineWidth: 2)
                        )
                        .offset(x: CGFloat(index) * -7)
                }
            }
            .padding(.trailing, 4)
            
            // Text
            if let firstInitials = reactorInitials.first {
                Text("\(firstInitials)")
                    .font(.rivaFacePile)
                    .foregroundColor(theme.sub)
                    .fontWeight(.semibold)
                + Text(" & \(totalReactors) others reacted")
                    .font(.rivaFacePile)
                    .foregroundColor(theme.muted)
            }
        }
    }
}

// MARK: - Reaction Bar
struct ReactionBar: View {
    let post: Post
    @Binding var firedByMe: Bool
    @Binding var strongByMe: Bool
    @Binding var savedByMe: Bool
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var fireTapCount = 0
    @State private var strongTapCount = 0
    @State private var commentTapCount = 0
    
    private var displayFireCount: Int {
        post.fireCount + (firedByMe ? 1 : 0)
    }
    
    private var displayStrongCount: Int {
        post.strongCount + (strongByMe ? 1 : 0)
    }
    
    private var displayCommentCount: Int {
        post.commentCount
    }
    
    private let feedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack(spacing: 16) {
            // Fire
            ReactionButton(
                icon: "flame.fill",
                count: displayFireCount,
                isActive: firedByMe,
                activeColor: Color.riva.fire,
                tapCount: fireTapCount,
                reduceMotion: reduceMotion
            )
            .onTapGesture {
                feedback.impactOccurred()
                firedByMe.toggle()
                fireTapCount += 1
            }
            
            // Strong
            ReactionButton(
                icon: "dumbbell.fill",
                count: displayStrongCount,
                isActive: strongByMe,
                activeColor: accent.color,
                tapCount: strongTapCount,
                reduceMotion: reduceMotion
            )
            .onTapGesture {
                feedback.impactOccurred()
                strongByMe.toggle()
                strongTapCount += 1
            }
            
            // Comment
            ReactionButton(
                icon: "bubble.left",
                count: displayCommentCount,
                isActive: false,
                activeColor: accent.color,
                tapCount: commentTapCount,
                reduceMotion: reduceMotion
            )
            .onTapGesture {
                feedback.impactOccurred()
                commentTapCount += 1
            }
            
            Spacer()
            
            // Bookmark
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    savedByMe.toggle()
                }
            }) {
                Image(systemName: savedByMe ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(savedByMe ? accent.color : theme.muted)
                    .contentTransition(.symbolEffect(.replace, options: .speed(2)))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}

// MARK: - Reaction Button (with spec bump animation)
private struct ReactionButton: View {
    let icon: String
    let count: Int
    let isActive: Bool
    let activeColor: Color
    let tapCount: Int
    let reduceMotion: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: isActive ? .bold : .medium))
                .contentTransition(.symbolEffect(.replace, options: .speed(2)))
                .phaseAnimator([1.0, 1.35, 1.0], trigger: tapCount) { image, scale in
                    image.scaleEffect(scale)
                } animation: { _ in
                        .timingCurve(0.34, 1.7, 0.5, 1, duration: reduceMotion ? 0 : 0.18)
                }
            
            Text("\(count)")
                .font(.rivaReactionCount)
        }
        .foregroundColor(isActive ? activeColor : .gray)
    }
}
