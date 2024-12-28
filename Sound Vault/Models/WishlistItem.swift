import Foundation

struct WishlistItem: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let artworkURL: URL?
    
    init(id: UUID = UUID(), title: String, artist: String, artworkURL: URL?) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
    }
    
    init(title: String, artist: String, artworkURLString: String?) {
        self.id = UUID()
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURLString.flatMap { URL(string: $0) }
    }
}
