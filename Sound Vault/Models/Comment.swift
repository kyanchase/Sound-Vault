import Foundation

struct SongComment: Identifiable, Codable {
    let id: String
    let text: String
    let userName: String
    let timestamp: Date
    
    init(id: String = UUID().uuidString, text: String, userName: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.userName = userName
        self.timestamp = timestamp
    }
} 