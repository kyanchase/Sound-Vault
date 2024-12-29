import Foundation

struct Song: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    let previewURL: URL?
    let albumName: String
    let spotifyURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case artist = "artists"
        case album
        case previewURL = "preview_url"
        case externalURLs = "external_urls"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        
        let artists = try container.decode([SpotifyArtist].self, forKey: .artist)
        artist = artists.map { $0.name }.joined(separator: ", ")
        
        let album = try container.decode(SpotifyAlbum.self, forKey: .album)
        albumName = album.name
        artworkURL = URL(string: album.images.first?.url ?? "")
        
        previewURL = try container.decodeIfPresent(URL.self, forKey: .previewURL)
        
        let externalURLs = try container.decode([String: String].self, forKey: .externalURLs)
        spotifyURL = URL(string: externalURLs["spotify"] ?? "")!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        // Note: We don't need to encode other fields since we don't send them back to Spotify
    }
    
    init(id: String, title: String, artist: String, artworkURL: URL?, previewURL: URL?, albumName: String, spotifyURL: URL) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.previewURL = previewURL
        self.albumName = albumName
        self.spotifyURL = spotifyURL
    }
} 