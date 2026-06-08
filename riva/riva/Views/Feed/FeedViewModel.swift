import Foundation
import Observation

@Observable
final class FeedViewModel {
    var posts: [Post] = []
    var selectedTab: RivaTab = .feed
    var isLoading = false
    var errorMessage: String?
    
    private let supabase = SupabaseService.shared
    
    var feedPosts: [Post] {
        posts
    }
    
    // MARK: - Load feed (sample data for now)
    func loadSampleFeed() {
        posts = Post.sampleFeed
    }
    
    // MARK: - Load from Supabase (when configured)
    @MainActor
    func loadFeed() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPosts = try await supabase.fetchFeedPosts()
            posts = fetchedPosts
        } catch {
            // Fall back to sample data if Supabase isn't configured
            if posts.isEmpty {
                posts = Post.sampleFeed
            }
            errorMessage = "Could not load feed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Tab switching
    func selectTab(_ tab: RivaTab) {
        selectedTab = tab
    }
    
}
