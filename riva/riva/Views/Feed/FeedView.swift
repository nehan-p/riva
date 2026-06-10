import SwiftUI

// MARK: - Feed View
struct FeedView: View {
    @State private var viewModel = FeedViewModel()
    @State private var showLogLift = false
    @EnvironmentObject private var sessionManager: SessionManager
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
                        
                        ForEach(viewModel.posts) { post in
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
            await viewModel.loadFeed()
        }
        .onChange(of: viewModel.selectedTab) { _, newTab in
            if newTab == .logLift {
                showLogLift = true
            }
        }
        .sheet(isPresented: $showLogLift, onDismiss: {
            viewModel.selectedTab = .feed
        }) {
            if let userId = sessionManager.currentUser?.id {
                LogLiftSheetView(userId: userId) {
                    await viewModel.loadFeed()
                }
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(SessionManager())
        .environment(\.rivaTheme, .ink)
        .environment(\.rivaAccent, .gold)
}
