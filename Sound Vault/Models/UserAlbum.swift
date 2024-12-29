import Foundation

struct UserAlbum: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    let releaseDate: Date?
    let rating: Int
    var isLiked: Bool
    let dateAdded: Date
    
    init(from album: Album, rating: Int = 0) {
        self.id = album.id
        self.title = album.title
        self.artist = album.artist
        self.artworkURL = album.artworkURL
        self.releaseDate = album.releaseDate
        self.rating = rating
        self.isLiked = false
        self.dateAdded = Date()
    }
    
    init(id: String, title: String, artist: String, artworkURL: URL?, rating: Int, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.releaseDate = nil
        self.rating = rating
        self.isLiked = false
        self.dateAdded = dateAdded
    }
} 