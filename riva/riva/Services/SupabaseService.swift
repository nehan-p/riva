import Foundation
import Supabase

// MARK: - Supabase Service
actor SupabaseService {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    private init() {
        guard let url = URL(string: Secrets.supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }
        let client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Secrets.supabaseAnonKey
        )
        // Suppress Supabase SDK session warning
        Task {
            _ = try? await client.auth.session
        }
        self.client = client
    }
    
    // MARK: - Auth
    func signIn(email: String, password: String) async throws {
        let _ = try await client.auth.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        let _ = try await client.auth.signUp(email: email, password: password)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    var currentSession: Supabase.Session? {
        get async {
            try? await client.auth.session
        }
    }
    
    var currentUserId: UUID? {
        get async {
            try? await client.auth.session.user.id
        }
    }
    
    // MARK: - Users
    func fetchUser(id: UUID) async throws -> RivaUser {
        let user: RivaUser = try await client
            .from("users")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
        return user
    }
    
    func fetchUsers(ids: [UUID]) async throws -> [RivaUser] {
        let users: [RivaUser] = try await client
            .from("users")
            .select()
            .in("id", values: ids)
            .execute()
            .value
        return users
    }
    
    // MARK: - Posts
    func fetchFeedPosts() async throws -> [Post] {
        let supabasePosts: [FeedPostRow] = try await client
            .from("posts")
            .select("""
                id, user_id, media_url, media_type, caption, is_pr, created_at,
                lifts(*)
            """)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return try await convertToPosts(supabasePosts)
    }
    
    private func convertToPosts(_ rows: [FeedPostRow]) async throws -> [Post] {
        var posts: [Post] = []
        for row in rows {
            let author = try? await fetchUser(id: row.userId)
            guard let author = author else { continue }
            let post = row.toPost(author: author)
            posts.append(post)
        }
        return posts
    }
    
    // MARK: - Reactions
    func toggleReaction(postId: UUID, userId: UUID, type: String, add: Bool) async throws {
        if add {
            try await client
                .from("reactions")
                .insert(ReactionInsert(postId: postId, userId: userId, type: type))
                .execute()
        } else {
            try await client
                .from("reactions")
                .delete()
                .eq("post_id", value: postId)
                .eq("user_id", value: userId)
                .eq("type", value: type)
                .execute()
        }
    }
    
    func fetchReactionCounts(postId: UUID) async throws -> [String: Int] {
        let reactions: [Reaction] = try await client
            .from("reactions")
            .select()
            .eq("post_id", value: postId)
            .execute()
            .value
        
        var counts: [String: Int] = [:]
        for reaction in reactions {
            counts[reaction.type, default: 0] += 1
        }
        return counts
    }
    
    // MARK: - Comments
    func fetchComments(postId: UUID) async throws -> [PostComment] {
        let comments: [PostComment] = try await client
            .from("comments")
            .select()
            .eq("post_id", value: postId)
            .order("created_at", ascending: true)
            .execute()
            .value
        return comments
    }
}

// MARK: - Feed Post Row (raw Supabase response)
struct FeedPostRow: Codable {
    let id: UUID
    let userId: UUID
    let mediaUrl: String?
    let mediaType: String?
    let caption: String?
    let isPr: Bool?
    let createdAt: String?
    let lifts: [Lift]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mediaUrl = "media_url"
        case mediaType = "media_type"
        case caption
        case isPr = "is_pr"
        case createdAt = "created_at"
        case lifts
    }
    
    func toPost(author: RivaUser) -> Post {
        let timeAgo = createdAt?.timeAgoDisplay() ?? "now"
        let tag: String
        if isPr == true {
            tag = lifts?.first?.exerciseName.uppercased() ?? "PR"
        } else if lifts?.isEmpty == false {
            tag = lifts?.first?.exerciseName.uppercased() ?? "WORKOUT"
        } else {
            tag = mediaType == "video" ? "CLIP" : "POST"
        }
        
        if isPr == true, let firstLift = lifts?.first {
            return .pr(PRPost(
                id: id, author: author, timeAgo: timeAgo, tag: tag,
                caption: caption ?? "",
                fireCount: 0, strongCount: 0, commentCount: 0,
                reactorInitials: [], totalReactors: 0,
                liftName: firstLift.exerciseName.uppercased(),
                weight: Int(firstLift.weight ?? 0),
                unit: firstLift.unit?.uppercased() ?? "LB",
                scheme: "\(firstLift.sets ?? 0) × \(firstLift.reps ?? 0)",
                previousWeight: Int((firstLift.weight ?? 0) - 20),
                gain: 20,
                supportLifts: Array((lifts ?? []).dropFirst().prefix(2)).map { lift in
                    Exercise(name: lift.exerciseName, weight: lift.weight, sets: lift.sets, reps: lift.reps, unit: lift.unit)
                }
            ))
        } else if mediaType == "video" {
            return .video(VideoPost(
                id: id, author: author, timeAgo: timeAgo, tag: tag,
                caption: caption ?? "",
                fireCount: 0, strongCount: 0, commentCount: 0,
                reactorInitials: [], totalReactors: 0,
                videoUrl: mediaUrl,
                workoutLabel: tag, duration: "1H 00M", videoLength: "0:30"
            ))
        } else if let mediaUrl = mediaUrl, !mediaUrl.isEmpty {
            return .photo(PhotoPost(
                id: id, author: author, timeAgo: timeAgo, tag: tag,
                caption: caption ?? "",
                fireCount: 0, strongCount: 0, commentCount: 0,
                reactorInitials: [], totalReactors: 0,
                imageUrl: mediaUrl, workoutLabel: tag, duration: "1H 00M"
            ))
        } else if let lifts = lifts, lifts.count >= 2 {
            let stats = WorkoutStats(
                duration: "1h 00m",
                volume: "\(lifts.reduce(0) { $0 + Int($1.weight ?? 0) })",
                sets: lifts.reduce(0) { $0 + ($1.sets ?? 0) }
            )
            return .session(SessionPost(
                id: id, author: author, timeAgo: timeAgo, tag: tag,
                caption: caption ?? "",
                fireCount: 0, strongCount: 0, commentCount: 0,
                reactorInitials: [], totalReactors: 0,
                title: "\(lifts.first?.exerciseName.uppercased() ?? "WORKOUT")",
                stats: stats,
                exercises: lifts.map { Exercise(name: $0.exerciseName, weight: $0.weight, sets: $0.sets, reps: $0.reps, unit: $0.unit) }
            ))
        } else {
            return .session(SessionPost(
                id: id, author: author, timeAgo: timeAgo, tag: tag,
                caption: caption ?? "",
                fireCount: 0, strongCount: 0, commentCount: 0,
                reactorInitials: [], totalReactors: 0,
                title: tag,
                stats: WorkoutStats(duration: "45m", volume: "0", sets: 0),
                exercises: (lifts ?? []).map { Exercise(name: $0.exerciseName, weight: $0.weight, sets: $0.sets, reps: $0.reps, unit: $0.unit) }
            ))
        }
    }
}

// MARK: - Helper types
struct ReactionInsert: Codable {
    let postId: UUID
    let userId: UUID
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case type
    }
}

// MARK: - String Date helpers
extension String {
    func timeAgoDisplay() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: self) ?? ISO8601DateFormatter().date(from: self) else {
            return "now"
        }
        let interval = Date().timeIntervalSince(date)
        switch interval {
        case ..<60: return "now"
        case ..<3600: return "\(Int(interval / 60))m ago"
        case ..<86400: return "\(Int(interval / 3600))h ago"
        case ..<604800: return "\(Int(interval / 86400))d ago"
        default: return "\(Int(interval / 604800))w ago"
        }
    }
}