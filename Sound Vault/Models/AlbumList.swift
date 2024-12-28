import Foundation

struct AlbumList: Identifiable, Codable {
    let id: String
    var title: String
    var description: String?
    var albums: [String] // Album IDs
    var isPublic: Bool
    let createdAt: Date
    var updatedAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: updatedAt)
    }
}
