import Foundation
import SwiftUI

// MARK: - Supabase User Model
struct RivaUser: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let username: String
    let email: String
    let profilePhotoUrl: String?
    let bio: String?
    let gender: String?
    let currentGoal: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, username, email, bio, gender
        case profilePhotoUrl = "profile_photo_url"
        case currentGoal = "current_goal"
        case createdAt = "created_at"
    }
    
    // MARK: - Avatar
    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2, let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)"
        }
        return String(name.prefix(2)).uppercased()
    }
    
    var avatarColor: Color {
        let key = String(name.prefix(2)).uppercased()
        switch key {
        case "JM": return Color.riva.avatarJM
        case "MR": return Color.riva.avatarMR
        case "SK": return Color.riva.avatarSK
        case "JT": return Color.riva.avatarJT
        case "AL": return Color.riva.avatarAL
        case "RP": return Color.riva.avatarRP
        case "MP": return Color.riva.avatarMP
        default:
            // Generate a deterministic color from the name
            let hash = name.hash
            let hue = Double(abs(hash) % 360) / 360.0
            return Color(hue: hue, saturation: 0.7, brightness: 0.8)
        }
    }
    
    // MARK: - Sample users
    static let jm = RivaUser(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
        name: "Jake Miller",
        username: "jakemiller",
        email: "jake@example.com",
        profilePhotoUrl: nil,
        bio: nil,
        gender: nil,
        currentGoal: "bulk",
        createdAt: nil
    )
    
    static let mr = RivaUser(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
        name: "Maya Reyes",
        username: "mayareyes",
        email: "maya@example.com",
        profilePhotoUrl: nil,
        bio: nil,
        gender: nil,
        currentGoal: "maintain",
        createdAt: nil
    )
    
    static let sk = RivaUser(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
        name: "Sam Kim",
        username: "samkim",
        email: "sam@example.com",
        profilePhotoUrl: nil,
        bio: nil,
        gender: nil,
        currentGoal: "cut",
        createdAt: nil
    )
    
    static let jt = RivaUser(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
        name: "John Torres",
        username: "johntorres",
        email: "john@example.com",
        profilePhotoUrl: nil,
        bio: nil,
        gender: nil,
        currentGoal: "bulk",
        createdAt: nil
    )
    
    static let al = RivaUser(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000005")!,
        name: "Amy Liu",
        username: "amyliu",
        email: "amy@example.com",
        profilePhotoUrl: nil,
        bio: nil,
        gender: nil,
        currentGoal: "maintain",
        createdAt: nil
    )
    
    static let rp = RivaUser(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
        name: "Ryan Park",
        username: "ryanpark",
        email: "ryan@example.com",
        profilePhotoUrl: nil,
        bio: nil,
        gender: nil,
        currentGoal: "cut",
        createdAt: nil
    )
    
    static let mp = RivaUser(
        id: UUID(uuidString: "10000000-0000-0000-0000-000000000007")!,
        name: "Maria Perez",
        username: "mariaperez",
        email: "maria@example.com",
        profilePhotoUrl: nil,
        bio: nil,
        gender: nil,
        currentGoal: "bulk",
        createdAt: nil
    )
}