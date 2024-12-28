import Foundation

struct UserSong: Identifiable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    let comment: String?
    let likes: Int
    let date: Date
    var isLiked: Bool
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 