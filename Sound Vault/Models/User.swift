import Foundation

struct User: Identifiable, Codable {
    let id: String
    var username: String
    var profileImage: String?
    var bio: String?
    var followers: [String] // User IDs
    var following: [String] // User IDs
    var songOfTheDay: SongOfTheDay?
    var albumLists: [AlbumList]
    var likedAlbums: [String] // Album IDs
    
    struct SongOfTheDay: Codable {
        let songId: String
        let date: Date
        let comment: String?
        let likes: Int
    }
}
