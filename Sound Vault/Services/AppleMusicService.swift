import Foundation
import MusicKit

@MainActor
class AppleMusicService: ObservableObject {
    @Published var isAuthorized = false
    
    init() {
        Task {
            isAuthorized = MusicAuthorization.currentStatus == .authorized
        }
    }
    
    func checkAuthorizationStatus() async {
        let status = await MusicAuthorization.request()
        isAuthorized = status == .authorized
    }
    
    func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        isAuthorized = status == .authorized
    }
    
    // Search for albums
    func searchAlbums(query: String) async throws -> [Album] {
        var request = MusicCatalogSearchRequest(term: query, types: [MusicKit.Album.self])
        request.limit = 25
        
        let response = try await request.response()
        return try await convertToAlbums(response.albums)
    }
    
    // Get album details
    func fetchAlbumDetails(id: MusicItemID) async throws -> Album {
        let request = MusicCatalogResourceRequest<MusicKit.Album>(matching: \.id, equalTo: id)
        let response = try await request.response()
        
        guard let musicAlbum = response.items.first else {
            throw NSError(domain: "AppleMusicService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Album not found"])
        }
        
        return try await convertToAlbum(musicAlbum)
    }
    
    // Get trending albums
    func fetchTrendingAlbums() async throws -> [Album] {
        var request = MusicCatalogSearchRequest(term: "", types: [MusicKit.Album.self])
        request.limit = 10
        
        let response = try await request.response()
        return try await convertToAlbums(response.albums)
    }
    
    // Get new releases
    func fetchNewReleases() async throws -> [Album] {
        var request = MusicCatalogSearchRequest(term: "", types: [MusicKit.Album.self])
        request.limit = 25
        
        let response = try await request.response()
        let allAlbums = response.albums
        
        // Filter albums by release date client-side
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let recentAlbums = allAlbums.filter { album in
            guard let releaseDate = album.releaseDate else { return false }
            return releaseDate >= oneMonthAgo
        }
        
        // Convert each album individually since we can't pass the filtered array directly
        var albums: [Album] = []
        for musicAlbum in recentAlbums {
            albums.append(try await convertToAlbum(musicAlbum))
        }
        return albums
    }
    
    // Helper function to convert MusicKit.Album to our Album model
    private func convertToAlbum(_ musicAlbum: MusicKit.Album) async throws -> Album {
        return Album(
            id: musicAlbum.id.rawValue,
            title: musicAlbum.title,
            artist: musicAlbum.artistName,
            artworkURL: musicAlbum.artwork?.url(width: 300, height: 300),
            releaseDate: musicAlbum.releaseDate ?? Date(),
            genre: musicAlbum.genreNames.first ?? "Unknown"
        )
    }
    
    // Helper function to convert array of MusicKit.Album to our Album model
    private func convertToAlbums(_ musicAlbums: MusicItemCollection<MusicKit.Album>) async throws -> [Album] {
        var albums: [Album] = []
        for musicAlbum in musicAlbums {
            albums.append(try await convertToAlbum(musicAlbum))
        }
        return albums
    }
    
    func searchMusic(query: String) async throws -> [MusicKit.Song] {
        let types: [any MusicCatalogSearchable.Type] = [Song.self as! any MusicCatalogSearchable.Type]
        var searchRequest = MusicCatalogSearchRequest(term: query, types: types)
        searchRequest.limit = 25

        let searchResponse = try await searchRequest.response()
        return Array(searchResponse.songs)
    }
    
    func convertToAlbum(_ song: MusicKit.Song) -> Album {
        Album(
            id: song.id.rawValue,
            title: song.title,
            artist: song.artistName,
            artworkURL: song.artwork?.url(width: 300, height: 300),
            releaseDate: song.releaseDate ?? Date(),
            genre: song.genreNames.first ?? "Unknown"
        )
    }
}
