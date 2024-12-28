import SwiftUI
import MusicKit

struct ExploreView: View {
    @ObservedObject var appleMusicService: AppleMusicService
    @ObservedObject var vaultViewModel: VaultViewModel
    @State private var searchText = ""
    @State private var topSongs: [Song] = []
    @State private var showingActionSheet = false
    @State private var selectedSong: Song?
    @State private var searchResults: [SearchResult] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if !appleMusicService.isAuthorized {
                        Button("Authorize Apple Music") {
                            Task {
                                await appleMusicService.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                    
                    // Search Bar
                    SearchBar(text: $searchText)
                        .onChange(of: searchText) { oldValue, newValue in
                            Task {
                                if appleMusicService.isAuthorized {
                                    try? await performSearch(query: newValue)
                                }
                            }
                        }
                    
                    if searchText.isEmpty {
                        // Top Songs of the Month
                        VStack(alignment: .leading) {
                            Text("Top Songs This Month")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 15) {
                                    ForEach(topSongs) { song in
                                        TopSongCard(song: song) {
                                            selectedSong = song
                                            showingActionSheet = true
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // Search Results
                        LazyVStack(spacing: 10) {
                            ForEach(searchResults) { item in
                                SearchResultRow(item: item) {
                                    selectedSong = item
                                    showingActionSheet = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if searchResults.isEmpty && !searchText.isEmpty {
                        Text("No results found")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .navigationTitle("Explore")
            .task {
                if appleMusicService.isAuthorized {
                    await loadTopSongs()
                }
            }
            .confirmationDialog("Add to Collection", isPresented: $showingActionSheet, titleVisibility: .visible) {
                Button("Add to Vault") {
                    if let song = selectedSong {
                        vaultViewModel.addToVault(song: song)
                    }
                }
                Button("Add to List") {
                    if let song = selectedSong {
                        vaultViewModel.addToList(song: song)
                    }
                }
                Button("Add to Wishlist") {
                    if let song = selectedSong {
                        vaultViewModel.addToWishlist(song: song)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    private func loadTopSongs() async {
        // Implement loading top songs from Apple Music API
        // This would fetch the current month's top songs
    }
    
    private func performSearch(query: String) async throws {
        // Implement combined search for songs, albums, and artists
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        var request = MusicCatalogSearchRequest(term: query, types: [MusicKit.Album.self, MusicKit.Artist.self, MusicKit.Song.self])
        request.limit = 25
        
        let response = try await request.response()
        searchResults = try await convertToSearchResults(response.albums, response.artists, response.songs)
    }
    
    private func convertToSearchResults(_ musicAlbums: MusicItemCollection<MusicKit.Album>, _ musicArtists: MusicItemCollection<MusicKit.Artist>, _ musicSongs: MusicItemCollection<MusicKit.Song>) async throws -> [SearchResult] {
        var searchResults: [SearchResult] = []
        for musicAlbum in musicAlbums {
            searchResults.append(try await convertToAlbum(musicAlbum))
        }
        for musicArtist in musicArtists {
            searchResults.append(try await convertToArtist(musicArtist))
        }
        for musicSong in musicSongs {
            searchResults.append(try await convertToSong(musicSong))
        }
        return searchResults
    }
    
    private func convertToAlbum(_ musicAlbum: MusicKit.Album) async throws -> SearchResult {
        return SearchResult(
            id: musicAlbum.id.rawValue,
            title: musicAlbum.title,
            artist: musicAlbum.artistName,
            artworkURL: musicAlbum.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
            releaseDate: musicAlbum.releaseDate ?? Date(),
            genre: musicAlbum.genreNames.first ?? "Unknown",
            type: .album
        )
    }
    
    private func convertToArtist(_ musicArtist: MusicKit.Artist) async throws -> SearchResult {
        return SearchResult(
            id: musicArtist.id.rawValue,
            title: musicArtist.name,
            artist: "",
            artworkURL: musicArtist.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
            releaseDate: nil,
            genre: musicArtist.genreNames.first ?? "Unknown",
            type: .artist
        )
    }
    
    private func convertToSong(_ musicSong: MusicKit.Song) async throws -> SearchResult {
        return SearchResult(
            id: musicSong.id.rawValue,
            title: musicSong.title,
            artist: musicSong.artistName,
            artworkURL: musicSong.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
            releaseDate: musicSong.releaseDate ?? Date(),
            genre: musicSong.genreNames.first ?? "Unknown",
            type: .song
        )
    }
}

struct TopSongCard: View {
    let song: Song
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                AsyncImage(url: song.artworkURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 150, height: 150)
                .cornerRadius(10)
                
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 150)
        }
    }
}

struct SearchResultRow: View {
    let item: SearchResult
    let action: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: item.artworkURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: action) {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.purple)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search albums, artists...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    var title: String
    var artist: String
    var artworkURL: String
    var releaseDate: Date?
    var genre: String
    var type: SearchResultType
    
    enum SearchResultType {
        case album
        case artist
        case song
    }
}

struct Song: Identifiable {
    let id = UUID()
    var title: String
    var artist: String
    var artworkURL: String
}
