import Foundation

struct UserSong: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let artworkURL: URL?
    var isLiked: Bool
    
    init(id: UUID = UUID(), title: String, artist: String, artworkURL: URL?, isLiked: Bool = false) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.isLiked = isLiked
    }
    
    init(title: String, artist: String, artworkURLString: String?, isLiked: Bool = false) {
        self.id = UUID()
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURLString.flatMap { URL(string: $0) }
        self.isLiked = isLiked
    }
}
