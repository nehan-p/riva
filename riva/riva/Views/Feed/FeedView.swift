import SwiftUI

// MARK: - Feed View
struct FeedView: View {
    @State private var viewModel = FeedViewModel()
    @Environment(\.rivaTheme) private var theme
    @Environment(\.rivaAccent) private var accent
    
    var body: some View {
        ZStack {
            // Background fills entire screen
            theme.background
                .ignoresSafeArea(.all)
            
            // Feed content layer
            VStack(spacing: 0) {
                StickyHeader()
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        LiveRail()
                            .padding(.top, 4)
                        
                        ForEach(viewModel.feedPosts) { post in
                            PostCard(post: post)
                                .padding(.top, 8)
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadFeed()
                }
                .safeAreaInset(edge: .bottom) {
                    RivaNavBar(selectedTab: $viewModel.selectedTab)
                }
            }
        }
        .task {
            viewModel.loadSampleFeed()
        }
    }
}

#Preview {
    FeedView()
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
}