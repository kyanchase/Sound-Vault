import Foundation

class FeedItem: Identifiable, ObservableObject {
    let id: String
    let username: String
    let userAvatarURL: URL?
    let songTitle: String
    let artistName: String
    let songArtworkURL: URL?
    let timestamp: String
    @Published var isLiked: Bool
    @Published var likeCount: Int
    
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: (() -> Void)?
    
    init(id: String, username: String, userAvatarURL: URL?, songTitle: String, artistName: String, songArtworkURL: URL?, timestamp: String, isLiked: Bool, likeCount: Int = 0, onLike: @escaping () -> Void, onComment: @escaping () -> Void, onShare: (() -> Void)? = nil) {
        self.id = id
        self.username = username
        self.userAvatarURL = userAvatarURL
        self.songTitle = songTitle
        self.artistName = artistName
        self.songArtworkURL = songArtworkURL
        self.timestamp = timestamp
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.onLike = onLike
        self.onComment = onComment
        self.onShare = onShare
    }
} 