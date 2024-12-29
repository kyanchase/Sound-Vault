import Foundation

struct UserActivity: Identifiable {
    let id: String
    let description: String
    let timestamp: Date
    let artworkURL: URL?
}
