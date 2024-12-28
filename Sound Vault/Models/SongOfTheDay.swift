import Foundation

struct SongOfTheDay: Identifiable, Codable {
    let id: String
    let songId: String
    let title: String
    let artist: String
    let artworkURL: String
    let date: Date
    var comment: String?
    var likes: Int
    
    init(songId: String, title: String, artist: String, artworkURL: String, date: Date, comment: String? = nil, likes: Int = 0) {
        self.id = UUID().uuidString
        self.songId = songId
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.date = date
        self.comment = comment
        self.likes = likes
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
