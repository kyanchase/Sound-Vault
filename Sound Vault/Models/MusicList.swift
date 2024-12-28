import Foundation

struct MusicList: Identifiable {
    let id: UUID
    var name: String
    var items: [UserSong]
    
    init(id: UUID = UUID(), name: String, items: [UserSong] = []) {
        self.id = id
        self.name = name
        self.items = items
    }
}
