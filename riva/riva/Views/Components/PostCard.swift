import SwiftUI

// MARK: - Post Card
struct PostCard: View {
    let post: Post
    @State private var firedByMe = false
    @State private var strongByMe = false
    @State private var savedByMe = false
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            PostHeader(post: post)
            
            // Body (varies by type)
            cardBody
            
            // Caption
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.rivaCaption)
                    .foregroundColor(theme.text)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
            }
            
            // Face pile
            if !post.reactorInitials.isEmpty {
                FacePile(reactorInitials: post.reactorInitials, totalReactors: post.totalReactors)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
            }
            
            // Reactions
            ReactionBar(
                post: post,
                firedByMe: $firedByMe,
                strongByMe: $strongByMe,
                savedByMe: $savedByMe
            )
        }
        .background(theme.surface)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(post.isEmphasis ? accent.color.opacity(0.5) : theme.line, lineWidth: post.isEmphasis ? 1.5 : 1)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 13)
    }
    
    @ViewBuilder
    private var cardBody: some View {
        switch post {
        case .photo(let p):
            PhotoCardBody(post: p)
        case .pr(let p):
            PRCardBody(post: p)
        case .session(let p):
            SessionCardBody(post: p)
        case .video(let p):
            VideoCardBody(post: p)
        case .milestone(let p):
            MilestoneCardBody(post: p)
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 0) {
            ForEach(Post.sampleFeed) { post in
                PostCard(post: post)
            }
        }
    }
    .background(Color.riva.inkBg)
    .environment(\.rivaTheme, .ink)
    .environment(\.rivaAccent, .gold)
}