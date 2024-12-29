import Foundation

// Spotify API Response Models
struct SpotifySearchResponse: Codable {
    let albums: SpotifyAlbums
}

struct SpotifyNewReleasesResponse: Codable {
    let albums: SpotifyAlbums
}

struct SpotifyAlbums: Codable {
    let items: [SpotifyAlbum]
}

struct SpotifyTrackSearchResponse: Codable {
    let tracks: SpotifyTracks
}

struct SpotifyTracks: Codable {
    let items: [SpotifyTrack]
}

struct SpotifyTrack: Codable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
    let previewURL: URL?
    let externalURLs: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case id, name, artists, album
        case previewURL = "preview_url"
        case externalURLs = "external_urls"
    }
}

struct SpotifyAlbum: Codable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let images: [SpotifyImage]
    let releaseDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, artists, images
        case releaseDate = "release_date"
    }
}

struct SpotifyArtist: Codable {
    let id: String
    let name: String
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

struct SpotifyFeaturedPlaylistsResponse: Codable {
    let message: String
    let playlists: SpotifyPagingObject<SpotifyPlaylist>
}

struct SpotifyPagingObject<T: Codable>: Codable {
    let items: [T]
    let total: Int
    let limit: Int
    let offset: Int
}

struct SpotifyPlaylist: Codable {
    let id: String
    let name: String
    let description: String?
    let images: [SpotifyImage]?
}

struct SpotifyPlaylistTracksResponse: Codable {
    let items: [SpotifyPlaylistTrackItem]
    let total: Int
    let limit: Int
    let offset: Int
}

struct SpotifyPlaylistTrackItem: Codable {
    let track: SpotifyTrack?
    let addedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case track
        case addedAt = "added_at"
    }
} 