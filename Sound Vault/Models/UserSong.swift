import Foundation

struct UserSong: Identifiable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    var isLiked: Bool
    var likeCount: Int
    var comments: [SongComment]
    
    init(id: String, title: String, artist: String, artworkURL: URL?, isLiked: Bool = false, likeCount: Int = 0, comments: [SongComment] = []) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.comments = comments
    }
    
    init(from song: Song) {
        self.id = song.id
        self.title = song.title
        self.artist = song.artist
        self.artworkURL = song.artworkURL
        self.isLiked = false
        self.likeCount = 0
        self.comments = []
    }
} 