import Foundation

struct UserActivity: Identifiable {
    let id: UUID
    let description: String
    let timestamp: Date
    let artworkURL: URL?
    
    init(id: UUID = UUID(), description: String, timestamp: Date = Date(), artworkURL: URL?) {
        self.id = id
        self.description = description
        self.timestamp = timestamp
        self.artworkURL = artworkURL
    }
    
    init(description: String, timestamp: Date = Date(), artworkURLString: String?) {
        self.id = UUID()
        self.description = description
        self.timestamp = timestamp
        self.artworkURL = artworkURLString.flatMap { URL(string: $0) }
    }
}
