import Foundation

struct User: Identifiable {
    let id: String
    let username: String
    let avatarURL: URL?
    let bio: String?
    let email: String
    var isFollowing: Bool
    
    // Additional user properties
    var followersCount: Int
    var followingCount: Int
    var vaultCount: Int
}
