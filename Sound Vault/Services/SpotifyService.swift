import Foundation

@MainActor
class SpotifyService: ObservableObject {
    @Published var isAuthorized = false
    @Published var authorizationError: String?
    
    // Spotify API credentials
    private let clientId = "af293f350ac94b76a702c202dff4f39f"
    private let clientSecret = "da79b1308f01453b8329559a7cb38e1c"
    private let baseURL = "https://api.spotify.com/v1"
    private var accessToken: String?
    
    init() {
        Task {
            await requestAuthorization()
        }
    }
    
    func requestAuthorization() async {
        #if targetEnvironment(simulator)
        isAuthorized = true
        #else
        do {
            let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
            var request = URLRequest(url: tokenURL)
            request.httpMethod = "POST"
            
            // Create the credentials string
            let credentials = "\(clientId):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
            request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
            
            // Add body parameters
            let bodyParams = "grant_type=client_credentials"
            request.httpBody = bodyParams.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Print response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("Authorization Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response Data: \(jsonString)")
            }
            
            let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
            
            await MainActor.run {
                self.accessToken = tokenResponse.accessToken
                self.isAuthorized = true
                self.authorizationError = nil
            }
        } catch {
            print("Authorization error: \(error)")
            let errorMessage = handleSpotifyError(error)
            await MainActor.run {
                self.isAuthorized = false
                self.authorizationError = errorMessage
            }
        }
        #endif
    }
    
    private func handleSpotifyError(_ error: Error) -> String {
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, _):
                return "Missing field in response: \(key.stringValue)"
            case .valueNotFound(_, let context):
                return "Missing value: \(context.debugDescription)"
            case .typeMismatch(_, let context):
                return "Type mismatch: \(context.debugDescription)"
            case .dataCorrupted(let context):
                return "Data corrupted: \(context.debugDescription)"
            @unknown default:
                return "Unknown decoding error"
            }
        } else {
            return error.localizedDescription
        }
    }
    
    private func makeAuthorizedRequest(_ url: URL) async throws -> (Data, URLResponse) {
        guard let token = accessToken else {
            throw SpotifyError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return try await URLSession.shared.data(for: request)
    }
    
    func searchAlbums(query: String) async throws -> [Album] {
        #if targetEnvironment(simulator)
        return mockAlbums
        #else
        guard let url = URL(string: "\(baseURL)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=album&limit=25") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await makeAuthorizedRequest(url)
        let response = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
        
        return response.albums.items.map { spotifyAlbum in
            Album(
                id: spotifyAlbum.id,
                title: spotifyAlbum.name,
                artist: spotifyAlbum.artists.first?.name ?? "Unknown Artist",
                artworkURL: URL(string: spotifyAlbum.images.first?.url ?? ""),
                releaseDate: ISO8601DateFormatter().date(from: spotifyAlbum.releaseDate) ?? Date(),
                genre: ""
            )
        }
        #endif
    }
    
    func fetchTrendingAlbums() async throws -> [Album] {
        #if targetEnvironment(simulator)
        return mockAlbums
        #else
        guard let url = URL(string: "\(baseURL)/browse/new-releases?limit=10") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await makeAuthorizedRequest(url)
        let response = try JSONDecoder().decode(SpotifyNewReleasesResponse.self, from: data)
        
        return response.albums.items.map { spotifyAlbum in
            Album(
                id: spotifyAlbum.id,
                title: spotifyAlbum.name,
                artist: spotifyAlbum.artists.first?.name ?? "Unknown Artist",
                artworkURL: URL(string: spotifyAlbum.images.first?.url ?? ""),
                releaseDate: ISO8601DateFormatter().date(from: spotifyAlbum.releaseDate) ?? Date(),
                genre: ""
            )
        }
        #endif
    }
    
    func fetchAlbum(id: String) async throws -> Album {
        #if targetEnvironment(simulator)
        return mockAlbums.first ?? Album(
            id: "1",
            title: "Unknown Album",
            artist: "Unknown Artist",
            artworkURL: nil,
            releaseDate: Date(),
            genre: ""
        )
        #else
        guard let url = URL(string: "\(baseURL)/albums/\(id)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await makeAuthorizedRequest(url)
        let spotifyAlbum = try JSONDecoder().decode(SpotifyAlbum.self, from: data)
        
        return Album(
            id: spotifyAlbum.id,
            title: spotifyAlbum.name,
            artist: spotifyAlbum.artists.first?.name ?? "Unknown Artist",
            artworkURL: URL(string: spotifyAlbum.images.first?.url ?? ""),
            releaseDate: ISO8601DateFormatter().date(from: spotifyAlbum.releaseDate) ?? Date(),
            genre: ""
        )
        #endif
    }
    
    func getRecommendedSongs(limit: Int = 1) async throws -> [Album] {
        #if targetEnvironment(simulator)
        return Array(mockAlbums.prefix(limit))
        #else
        if !isAuthorized {
            await requestAuthorization()
        }
        
        guard isAuthorized, let accessToken = accessToken else {
            throw SpotifyError.unauthorized
        }
        
        // Get new releases instead of playlist tracks
        guard let newReleasesURL = URL(string: "\(baseURL)/browse/new-releases?limit=50&offset=\(Int.random(in: 0..<50))&country=US") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: newReleasesURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug print
        if let httpResponse = response as? HTTPURLResponse {
            print("New Releases Status Code: \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("New Releases Response: \(jsonString)")
        }
        
        let newReleasesResponse = try JSONDecoder().decode(SpotifyNewReleasesResponse.self, from: data)
        
        // Convert albums to our Album model
        let albums = newReleasesResponse.albums.items.map { spotifyAlbum in
            Album(
                id: spotifyAlbum.id,
                title: spotifyAlbum.name,
                artist: spotifyAlbum.artists.first?.name ?? "Unknown Artist",
                artworkURL: URL(string: spotifyAlbum.images.first?.url ?? ""),
                releaseDate: ISO8601DateFormatter().date(from: spotifyAlbum.releaseDate) ?? Date(),
                genre: ""
            )
        }
        
        // Return random albums up to the limit
        let shuffledAlbums = albums.shuffled()
        return Array(shuffledAlbums.prefix(limit))
        #endif
    }
    
    func searchSongs(query: String) async throws -> [Song] {
        #if targetEnvironment(simulator)
        return mockSongs
        #else
        guard let url = URL(string: "\(baseURL)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=track&limit=25") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await makeAuthorizedRequest(url)
        let response = try JSONDecoder().decode(SpotifyTrackSearchResponse.self, from: data)
        
        return response.tracks.items.map { track in
            Song(
                id: track.id,
                title: track.name,
                artist: track.artists.map { $0.name }.joined(separator: ", "),
                artworkURL: URL(string: track.album.images.first?.url ?? ""),
                previewURL: track.previewURL,
                albumName: track.album.name,
                spotifyURL: URL(string: track.externalURLs["spotify"] ?? "")!
            )
        }
        #endif
    }
    
    // Mock data for simulator
    private var mockAlbums: [Album] = [
        Album(
            id: "1",
            title: "Midnights",
            artist: "Taylor Swift",
            artworkURL: URL(string: "https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5"),
            releaseDate: Date(),
            genre: "Pop"
        ),
        Album(
            id: "2",
            title: "Renaissance",
            artist: "Beyoncé",
            artworkURL: URL(string: "https://i.scdn.co/image/ab67616d0000b273a0b0d1e93e0d0129a187fe9a"),
            releaseDate: Date(),
            genre: "Pop"
        ),
        Album(
            id: "3",
            title: "Un Verano Sin Ti",
            artist: "Bad Bunny",
            artworkURL: URL(string: "https://i.scdn.co/image/ab67616d0000b273d105b87eb0e8b06c4a7b4f55"),
            releaseDate: Date(),
            genre: "Latin"
        )
    ]
    
    private var mockSongs: [Song] = [
        Song(
            id: "1",
            title: "Anti-Hero",
            artist: "Taylor Swift",
            artworkURL: URL(string: "https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5"),
            previewURL: nil,
            albumName: "Midnights",
            spotifyURL: URL(string: "https://open.spotify.com/track/1")!
        ),
        Song(
            id: "2",
            title: "Break My Soul",
            artist: "Beyoncé",
            artworkURL: URL(string: "https://i.scdn.co/image/ab67616d0000b273a0b0d1e93e0d0129a187fe9a"),
            previewURL: nil,
            albumName: "Renaissance",
            spotifyURL: URL(string: "https://open.spotify.com/track/2")!
        )
    ]
}

enum SpotifyError: LocalizedError {
    case unauthorized
    case invalidResponse
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Not authorized. Please check your Spotify credentials."
        case .invalidResponse:
            return "Invalid response from Spotify API"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 