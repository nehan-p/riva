import Foundation
import SwiftUI

// MARK: - Exercise in a workout
struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let weight: Double?
    let sets: Int?
    let reps: Int?
    let unit: String?
    
    var displayScheme: String {
        "\(sets ?? 0) × \(reps ?? 0)"
    }
    
    var displayWeight: String {
        guard let weight = weight else { return "—" }
        return "\(Int(weight)) \(unit ?? "lbs")"
    }
    
    init(id: UUID = UUID(), name: String, weight: Double?, sets: Int?, reps: Int?, unit: String? = "lbs") {
        self.id = id
        self.name = name
        self.weight = weight
        self.sets = sets
        self.reps = reps
        self.unit = unit
    }
    
    // Supabase CodingKeys
    enum CodingKeys: String, CodingKey {
        case id, name, weight, sets, reps, unit
    }
    
    // MARK: - Sample exercises
    static let sampleExercises = [
        Exercise(name: "Squat", weight: 225, sets: 3, reps: 5),
        Exercise(name: "Bench Press", weight: 185, sets: 4, reps: 8),
        Exercise(name: "Barbell Row", weight: 155, sets: 3, reps: 8),
        Exercise(name: "Deadlift", weight: 315, sets: 3, reps: 5),
        Exercise(name: "Overhead Press", weight: 95, sets: 4, reps: 8),
        Exercise(name: "Pull Up", weight: nil, sets: 3, reps: 10),
        Exercise(name: "Leg Press", weight: 405, sets: 3, reps: 12),
        Exercise(name: "Dumbbell Curl", weight: 30, sets: 3, reps: 12),
    ]
}

// MARK: - Workout Stats
struct WorkoutStats: Codable, Equatable {
    let duration: String
    let volume: String
    let sets: Int
    
    static let sample = WorkoutStats(duration: "1h 18m", volume: "28,450", sets: 22)
    static let samplePush = WorkoutStats(duration: "1h 02m", volume: "18,200", sets: 18)
}

// MARK: - Post Model (enum-based)
enum Post: Identifiable, Equatable {
    case photo(PhotoPost)
    case pr(PRPost)
    case session(SessionPost)
    case video(VideoPost)
    case milestone(MilestonePost)
    
    var id: UUID {
        switch self {
        case .photo(let p): return p.id
        case .pr(let p): return p.id
        case .session(let p): return p.id
        case .video(let p): return p.id
        case .milestone(let p): return p.id
        }
    }
    
    var author: RivaUser {
        switch self {
        case .photo(let p): return p.author
        case .pr(let p): return p.author
        case .session(let p): return p.author
        case .video(let p): return p.author
        case .milestone(let p): return p.author
        }
    }
    
    var handleTime: String {
        switch self {
        case .photo(let p): return "@\(p.author.username) · \(p.timeAgo)"
        case .pr(let p): return "@\(p.author.username) · \(p.timeAgo)"
        case .session(let p): return "@\(p.author.username) · \(p.timeAgo)"
        case .video(let p): return "@\(p.author.username) · \(p.timeAgo)"
        case .milestone(let p): return "@\(p.author.username) · \(p.timeAgo)"
        }
    }
    
    var tag: String {
        switch self {
        case .photo(let p): return p.tag
        case .pr(let p): return p.tag
        case .session(let p): return p.tag
        case .video(let p): return p.tag
        case .milestone(let p): return p.tag
        }
    }
    
    var caption: String {
        switch self {
        case .photo(let p): return p.caption
        case .pr(let p): return p.caption
        case .session(let p): return p.caption
        case .video(let p): return p.caption
        case .milestone(let p): return p.caption
        }
    }
    
    var fireCount: Int {
        switch self {
        case .photo(let p): return p.fireCount
        case .pr(let p): return p.fireCount
        case .session(let p): return p.fireCount
        case .video(let p): return p.fireCount
        case .milestone(let p): return p.fireCount
        }
    }
    
    var strongCount: Int {
        switch self {
        case .photo(let p): return p.strongCount
        case .pr(let p): return p.strongCount
        case .session(let p): return p.strongCount
        case .video(let p): return p.strongCount
        case .milestone(let p): return p.strongCount
        }
    }
    
    var commentCount: Int {
        switch self {
        case .photo(let p): return p.commentCount
        case .pr(let p): return p.commentCount
        case .session(let p): return p.commentCount
        case .video(let p): return p.commentCount
        case .milestone(let p): return p.commentCount
        }
    }
    
    var reactorInitials: [String] {
        switch self {
        case .photo(let p): return p.reactorInitials
        case .pr(let p): return p.reactorInitials
        case .session(let p): return p.reactorInitials
        case .video(let p): return p.reactorInitials
        case .milestone(let p): return p.reactorInitials
        }
    }
    
    var totalReactors: Int {
        switch self {
        case .photo(let p): return p.totalReactors
        case .pr(let p): return p.totalReactors
        case .session(let p): return p.totalReactors
        case .video(let p): return p.totalReactors
        case .milestone(let p): return p.totalReactors
        }
    }
    
    var isEmphasis: Bool {
        switch self {
        case .pr, .milestone: return true
        default: return false
        }
    }
}

// MARK: - Shared Post Data
struct SharedPostData: Equatable {
    let id: UUID
    let author: RivaUser
    let timeAgo: String
    let tag: String
    let caption: String
    let fireCount: Int
    let strongCount: Int
    let commentCount: Int
    let reactorInitials: [String]
    let totalReactors: Int
    
    static let facePileInitials = ["MR", "SK", "JT"]
    static let sampleComment = "\"Love hitting legs on Monday 🔥\""
}

// MARK: - Photo Post
struct PhotoPost: Equatable {
    let id: UUID
    let author: RivaUser
    let timeAgo: String
    let tag: String
    let caption: String
    let fireCount: Int
    let strongCount: Int
    let commentCount: Int
    let reactorInitials: [String]
    let totalReactors: Int
    let imageUrl: String?
    let workoutLabel: String
    let duration: String
    
    var shared: SharedPostData {
        SharedPostData(id: id, author: author, timeAgo: timeAgo, tag: tag, caption: caption,
                       fireCount: fireCount, strongCount: strongCount, commentCount: commentCount,
                       reactorInitials: reactorInitials, totalReactors: totalReactors)
    }
    
    static let sample = PhotoPost(
        id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
        author: .jt,
        timeAgo: "2h ago",
        tag: "PUSH DAY",
        caption: "Felt strong today. Working on that mind-muscle connection on incline press. Form over ego 💪",
        fireCount: 142,
        strongCount: 89,
        commentCount: 24,
        reactorInitials: SharedPostData.facePileInitials,
        totalReactors: 184,
        imageUrl: nil,
        workoutLabel: "LEG DAY",
        duration: "1H 02M"
    )
}

// MARK: - PR Post
struct PRPost: Equatable {
    let id: UUID
    let author: RivaUser
    let timeAgo: String
    let tag: String
    let caption: String
    let fireCount: Int
    let strongCount: Int
    let commentCount: Int
    let reactorInitials: [String]
    let totalReactors: Int
    let liftName: String
    let weight: Int
    let unit: String
    let scheme: String
    let previousWeight: Int
    let gain: Int
    let supportLifts: [Exercise]
    
    var shared: SharedPostData {
        SharedPostData(id: id, author: author, timeAgo: timeAgo, tag: tag, caption: caption,
                       fireCount: fireCount, strongCount: strongCount, commentCount: commentCount,
                       reactorInitials: reactorInitials, totalReactors: totalReactors)
    }
    
    static let sample = PRPost(
        id: UUID(uuidString: "20000000-0000-0000-0000-000000000002")!,
        author: .jm,
        timeAgo: "4h ago",
        tag: "DEADLIFT",
        caption: "Chasing that 500 lb club. Felt super solid off the floor today.",
        fireCount: 231,
        strongCount: 156,
        commentCount: 42,
        reactorInitials: SharedPostData.facePileInitials,
        totalReactors: 312,
        liftName: "DEADLIFT",
        weight: 475,
        unit: "LB",
        scheme: "3 × 3",
        previousWeight: 455,
        gain: 20,
        supportLifts: [
            Exercise(name: "Deficit Deadlift", weight: 405, sets: 3, reps: 5),
            Exercise(name: "RDL", weight: 315, sets: 4, reps: 8),
        ]
    )
}

// MARK: - Session Post (non-PR)
struct SessionPost: Equatable {
    let id: UUID
    let author: RivaUser
    let timeAgo: String
    let tag: String
    let caption: String
    let fireCount: Int
    let strongCount: Int
    let commentCount: Int
    let reactorInitials: [String]
    let totalReactors: Int
    let title: String
    let stats: WorkoutStats
    let exercises: [Exercise]
    
    var shared: SharedPostData {
        SharedPostData(id: id, author: author, timeAgo: timeAgo, tag: tag, caption: caption,
                       fireCount: fireCount, strongCount: strongCount, commentCount: commentCount,
                       reactorInitials: reactorInitials, totalReactors: totalReactors)
    }
    
    static let sample = SessionPost(
        id: UUID(uuidString: "20000000-0000-0000-0000-000000000003")!,
        author: .mr,
        timeAgo: "1h ago",
        tag: "UPPER",
        caption: "Upper body pump before the weekend. Trying out some new accessories.",
        fireCount: 64,
        strongCount: 38,
        commentCount: 9,
        reactorInitials: SharedPostData.facePileInitials,
        totalReactors: 87,
        title: "UPPER BODY",
        stats: WorkoutStats.samplePush,
        exercises: [
            Exercise(name: "Bench Press", weight: 135, sets: 4, reps: 8),
            Exercise(name: "DB Shoulder Press", weight: 40, sets: 3, reps: 12),
            Exercise(name: "Cable Row", weight: 120, sets: 3, reps: 12),
            Exercise(name: "Lateral Raise", weight: 15, sets: 4, reps: 15),
        ]
    )
}

// MARK: - Video Post
struct VideoPost: Equatable {
    let id: UUID
    let author: RivaUser
    let timeAgo: String
    let tag: String
    let caption: String
    let fireCount: Int
    let strongCount: Int
    let commentCount: Int
    let reactorInitials: [String]
    let totalReactors: Int
    let videoUrl: String?
    let workoutLabel: String
    let duration: String
    let videoLength: String
    
    var shared: SharedPostData {
        SharedPostData(id: id, author: author, timeAgo: timeAgo, tag: tag, caption: caption,
                       fireCount: fireCount, strongCount: strongCount, commentCount: commentCount,
                       reactorInitials: reactorInitials, totalReactors: totalReactors)
    }
    
    static let sample = VideoPost(
        id: UUID(uuidString: "20000000-0000-0000-0000-000000000004")!,
        author: .rp,
        timeAgo: "6h ago",
        tag: "BACK",
        caption: "Paused deadlifts — really focusing on that initial pull off the floor.",
        fireCount: 88,
        strongCount: 72,
        commentCount: 15,
        reactorInitials: SharedPostData.facePileInitials,
        totalReactors: 135,
        videoUrl: nil,
        workoutLabel: "DEADLIFT",
        duration: "1H 30M",
        videoLength: "0:14"
    )
}

// MARK: - Milestone Post
struct MilestonePost: Equatable {
    let id: UUID
    let author: RivaUser
    let timeAgo: String
    let tag: String
    let caption: String
    let fireCount: Int
    let strongCount: Int
    let commentCount: Int
    let reactorInitials: [String]
    let totalReactors: Int
    let milestoneNumeral: Int
    let milestoneLabel: String
    let milestoneSub: String
    
    var shared: SharedPostData {
        SharedPostData(id: id, author: author, timeAgo: timeAgo, tag: tag, caption: caption,
                       fireCount: fireCount, strongCount: strongCount, commentCount: commentCount,
                       reactorInitials: reactorInitials, totalReactors: totalReactors)
    }
    
    static let sample = MilestonePost(
        id: UUID(uuidString: "20000000-0000-0000-0000-000000000005")!,
        author: .sk,
        timeAgo: "12h ago",
        tag: "MILESTONE",
        caption: "One month straight. No excuses.",
        fireCount: 315,
        strongCount: 203,
        commentCount: 67,
        reactorInitials: SharedPostData.facePileInitials,
        totalReactors: 440,
        milestoneNumeral: 30,
        milestoneLabel: "DAY STREAK",
        milestoneSub: "Stay consistent. The results will come."
    )
}

// MARK: - Sample Feed Data
extension Post {
    static let sampleFeed: [Post] = [
        .photo(.sample),
        .pr(.sample),
        .session(.sample),
        .video(.sample),
        .milestone(.sample),
    ]
}

// MARK: - Lift (Supabase model)
struct Lift: Identifiable, Codable {
    let id: UUID
    let postId: UUID
    let exerciseName: String
    let weight: Double?
    let sets: Int?
    let reps: Int?
    let unit: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case exerciseName = "exercise_name"
        case weight, sets, reps, unit
    }
}

// MARK: - Reaction (Supabase model)
struct Reaction: Identifiable, Codable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let type: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case type
        case createdAt = "created_at"
    }
}

// MARK: - Comment (Supabase model)
struct PostComment: Identifiable, Codable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let body: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case body
        case createdAt = "created_at"
    }
}