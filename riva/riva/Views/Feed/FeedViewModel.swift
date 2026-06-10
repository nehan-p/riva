import Foundation
import Observation
import os

@Observable
final class FeedViewModel {
    var posts: [Post] = []
    var selectedTab: RivaTab = .feed
    var isLoading = false
    var errorMessage: String?

    private let supabase = SupabaseService.shared
    private let logger = Logger(subsystem: "com.riva", category: "FeedViewModel")

    // MARK: - Load from Supabase
    @MainActor
    func loadFeed() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedPosts = try await supabase.fetchFeedPosts()
            posts = fetchedPosts
        } catch {
            logger.error("Failed to load feed: \(error.localizedDescription)")
            posts = []
            errorMessage = nil
        }

        isLoading = false
    }

    // MARK: - Tab switching
    func selectTab(_ tab: RivaTab) {
        selectedTab = tab
    }
}