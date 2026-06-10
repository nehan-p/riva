import Foundation
import Supabase
import UIKit

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
    
    /// Returns whether the sign-up requires email confirmation.
    func signUpWithRedirect(email: String, password: String) async throws -> Bool {
        let response = try await client.auth.signUp(
            email: email,
            password: password
        )
        // If no session was returned, email confirmation is required
        return response.session == nil
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func resetPasswordForEmail(_ email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    /// Exchanges the auth code from a deep link verification URL to set the session.
    func exchangeAuthCode(from url: URL) async throws {
        try await client.auth.session(from: url)
    }
    
    // MARK: - Auth State Stream
    
    /// Exposes auth state changes so MainActor SessionManager can listen.
    /// Returns a tuple of (AuthChangeEvent, Session?) for each state change.
    func authStateChanges() -> AsyncStream<(AuthChangeEvent, Session?)> {
        AsyncStream { continuation in
            let task = Task {
                for await (event, session) in client.auth.authStateChanges {
                    continuation.yield((event, session))
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
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
    
    // MARK: - Profiles
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let response = try await client
            .from("users")
            .select("*", head: true, count: .exact)
            .eq("username", value: username.lowercased())
            .execute()
        // Count is in the response count — head query returns no rows
        let count = response.count ?? 0
        return count == 0
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
    
    // MARK: - Log Lift
    func checkPersonalBest(userId: UUID, exerciseName: String, weight: Double, unit: String) async throws -> Bool {
        let userPosts: [PostIdRow] = try await client
            .from("posts")
            .select("id")
            .eq("user_id", value: userId)
            .execute()
            .value
        let postIds = userPosts.map { $0.id }
        guard !postIds.isEmpty else { return false }
        let lifts: [MaxWeightRow] = try await client
            .from("lifts")
            .select("weight")
            .in("post_id", values: postIds)
            .eq("exercise_name", value: exerciseName)
            .eq("unit", value: unit)
            .order("weight", ascending: false)
            .limit(1)
            .execute()
            .value
        guard let bestLift = lifts.first, let previousBest = bestLift.weight else { return false }
        return weight > previousBest
    }
    
    func uploadImage(userId: UUID, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw SupabaseError.mediaCompressionFailed
        }
        let fileName = "\(UUID().uuidString).jpg"
        let path = "\(userId.uuidString)/\(fileName)"
        try await client.storage
            .from("post-media")
            .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg", upsert: false))
        let publicURL = try client.storage.from("post-media").getPublicURL(path: path)
        return publicURL.absoluteString
    }
    
    func uploadVideo(userId: UUID, fileURL: URL) async throws -> String {
        let videoData = try Data(contentsOf: fileURL)
        let pathExtension = fileURL.pathExtension.isEmpty ? "mov" : fileURL.pathExtension
        let fileName = "\(UUID().uuidString).\(pathExtension)"
        let path = "\(userId.uuidString)/\(fileName)"
        let mimeType = pathExtension.lowercased() == "mp4" ? "video/mp4" : "video/quicktime"
        try await client.storage
            .from("post-media")
            .upload(path, data: videoData, options: FileOptions(contentType: mimeType, upsert: false))
        let publicURL = try client.storage.from("post-media").getPublicURL(path: path)
        return publicURL.absoluteString
    }
    
    func createPost(
        userId: UUID, exerciseName: String, weight: Double, sets: Int, reps: Int,
        unit: String, isPR: Bool, caption: String?, mediaURL: String?, mediaType: String?
    ) async throws {
        let postInsert = PostInsert(userId: userId, mediaUrl: mediaURL, mediaType: mediaType, caption: caption, isPr: isPR)
        let createdPost: PostIdRow = try await client
            .from("posts")
            .insert(postInsert)
            .select("id")
            .single()
            .execute()
            .value
        let liftInsert = LiftInsert(postId: createdPost.id, exerciseName: exerciseName, weight: weight, sets: sets, reps: reps, unit: unit)
        try await client.from("lifts").insert(liftInsert).execute()
    }
    
    // MARK: - PR Helpers
    
    /// Returns the previous best weight for a given user/exercise/unit, excluding a specific post.
    func fetchPreviousBestWeight(userId: UUID, exerciseName: String, unit: String, excludingPostId: UUID? = nil) async throws -> Double? {
        let userPosts: [PostIdRow] = try await client
            .from("posts")
            .select("id")
            .eq("user_id", value: userId)
            .execute()
            .value
        let postIds = userPosts.map { $0.id }.filter { $0 != excludingPostId }
        guard !postIds.isEmpty else { return nil }
        let lifts: [MaxWeightRow] = try await client
            .from("lifts")
            .select("weight")
            .in("post_id", values: postIds)
            .eq("exercise_name", value: exerciseName)
            .eq("unit", value: unit)
            .order("weight", ascending: false)
            .limit(1)
            .execute()
            .value
        return lifts.first?.weight
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
        guard !rows.isEmpty else { return [] }
        let uniqueUserIds = Array(Set(rows.map(\.userId)))
        let users = (try? await fetchUsers(ids: uniqueUserIds)) ?? []
        let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
        var posts: [Post] = []
        for row in rows {
            guard let author = userMap[row.userId] else { continue }
            posts.append(row.toPost(author: author))
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
    
    func toPost(author: RivaUser, previousBest: Double? = nil) -> Post {
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
            let currentWeight = Int(firstLift.weight ?? 0)
            let prevWeight = previousBest.map { Int($0) } ?? currentWeight
            let computedGain = currentWeight - prevWeight
            return .pr(PRPost(
                id: id, author: author, timeAgo: timeAgo, tag: tag,
                caption: caption ?? "",
                fireCount: 0, strongCount: 0, commentCount: 0,
                reactorInitials: [], totalReactors: 0,
                liftName: firstLift.exerciseName.uppercased(),
                weight: currentWeight,
                unit: firstLift.unit?.uppercased() ?? "LB",
                scheme: "\(firstLift.sets ?? 0) × \(firstLift.reps ?? 0)",
                previousWeight: prevWeight,
                gain: computedGain,
                supportLifts: Array((lifts ?? []).dropFirst().prefix(2)).map { lift in
                    Exercise(name: lift.exerciseName, weight: lift.weight, sets: lift.sets, reps: lift.reps, unit: lift.unit)
                },
                mediaUrl: mediaUrl,
                mediaType: mediaType
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
struct PostInsert: Codable {
    let userId: UUID
    let mediaUrl: String?
    let mediaType: String?
    let caption: String?
    let isPr: Bool
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case mediaUrl = "media_url"
        case mediaType = "media_type"
        case caption
        case isPr = "is_pr"
    }
}

struct LiftInsert: Codable {
    let postId: UUID
    let exerciseName: String
    let weight: Double
    let sets: Int
    let reps: Int
    let unit: String
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case exerciseName = "exercise_name"
        case weight, sets, reps, unit
    }
}

struct PostIdRow: Codable {
    let id: UUID
}

struct MaxWeightRow: Codable {
    let weight: Double?
}

enum SupabaseError: LocalizedError {
    case mediaCompressionFailed
    var errorDescription: String? {
        switch self {
        case .mediaCompressionFailed: return "Failed to compress image for upload."
        }
    }
}

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
fileprivate extension String {
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