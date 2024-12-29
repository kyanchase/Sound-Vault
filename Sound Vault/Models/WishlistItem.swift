import Foundation

struct WishlistItem: Identifiable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
}
