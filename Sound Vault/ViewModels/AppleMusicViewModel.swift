import Foundation
import MusicKit

@MainActor
class AppleMusicViewModel: ObservableObject {
    private let musicService = AppleMusicService()
    
    @Published var isAuthorized = false
    @Published var trendingAlbums: [Album] = []
    @Published var newReleases: [Album] = []
    @Published var searchResults: [Album] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        Task {
            await checkAuthorization()
        }
    }
    
    func checkAuthorization() async {
        await musicService.checkAuthorizationStatus()
        isAuthorized = musicService.isAuthorized
    }
    
    func requestAuthorization() async {
        await musicService.requestAuthorization()
        isAuthorized = musicService.isAuthorized
        
        if isAuthorized {
            await fetchInitialData()
        }
    }
    
    func fetchInitialData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let trendingTask = musicService.fetchTrendingAlbums()
            async let newReleasesTask = musicService.fetchNewReleases()
            
            let (trending, newReleases) = try await (trendingTask, newReleasesTask)
            
            self.trendingAlbums = trending
            self.newReleases = newReleases
        } catch {
            errorMessage = "Failed to load music data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func searchAlbums(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            searchResults = try await musicService.searchAlbums(query: query)
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            searchResults = []
        }
        
        isLoading = false
    }
    
    func fetchAlbumDetails(id: String) async throws -> Album {
        return try await musicService.fetchAlbumDetails(id: MusicItemID(id))
    }
}
