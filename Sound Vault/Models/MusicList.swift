import Foundation

struct MusicList: Identifiable {
    let id: String
    var name: String
    var items: [UserAlbum]
}
