import SwiftUI

struct ExploreView: View {
    @ObservedObject var spotifyService: SpotifyService
    @ObservedObject var vaultViewModel: VaultViewModel
    @State private var searchText = ""
    @State private var topAlbums: [Album] = []
    @State private var selectedAlbum: Album?
    @State private var searchResults: [SearchResult] = []
    @State private var isShowingUserProfile = false
    @State private var selectedUserId: String?
    @State private var showingAlbumDetail = false
    
    private let userService: UserService
    
    init(spotifyService: SpotifyService, vaultViewModel: VaultViewModel) {
        self.spotifyService = spotifyService
        self.vaultViewModel = vaultViewModel
        self.userService = vaultViewModel.userService
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    authorizationButton
                    
                    SearchBar(text: $searchText)
                        .onChange(of: searchText) { oldValue, newValue in
                            handleSearchTextChange(newValue)
                        }
                    
                    if searchText.isEmpty {
                        TopAlbumsSection(
                            topAlbums: topAlbums,
                            onAlbumSelected: { album in
                                selectedAlbum = album
                                showingAlbumDetail = true
                            }
                        )
                    } else {
                        SearchResultsSection(
                            results: searchResults,
                            spotifyService: spotifyService,
                            onAlbumSelected: { album in
                                selectedAlbum = album
                                showingAlbumDetail = true
                            },
                            onUserSelected: navigateToUserProfile,
                            viewModel: vaultViewModel
                        )
                        
                        if searchResults.isEmpty {
                            Text("No results found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            .task {
                if spotifyService.isAuthorized {
                    await loadTopAlbums()
                }
            }
            .sheet(isPresented: $showingAlbumDetail) {
                if let album = selectedAlbum {
                    AlbumDetailView(album: album, viewModel: vaultViewModel)
                }
            }
            .sheet(isPresented: $isShowingUserProfile) {
                if let userId = selectedUserId {
                    NavigationView {
                        UserProfileView(userId: userId, viewModel: UserProfileViewModel(userService: userService))
                    }
                }
            }
        }
    }
    
    private var authorizationButton: some View {
        Group {
            if !spotifyService.isAuthorized {
                Button("Authorize Spotify") {
                    Task {
                        await spotifyService.requestAuthorization()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
    }
    
    private func loadTopAlbums() async {
        do {
            let albums = try await spotifyService.fetchTrendingAlbums()
            await MainActor.run {
                self.topAlbums = albums
            }
        } catch {
            print("Error loading top albums: \(error)")
        }
    }
    
    private func handleSearchTextChange(_ query: String) {
        Task {
            if spotifyService.isAuthorized {
                do {
                    try await performSearch(query: query)
                } catch {
                    print("Search error: \(error)")
                }
            }
        }
    }
    
    private func performSearch(query: String) async throws {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let albums = try await spotifyService.searchAlbums(query: query)
        var results = albums.map { album in
            SearchResult(
                id: album.id,
                title: album.title,
                artist: album.artist,
                artworkURL: album.artworkURL?.absoluteString ?? "",
                releaseDate: album.releaseDate,
                genre: album.genre,
                type: .album
            )
        }
        
        // Search for users
        do {
            let userResults = try await userService.searchUsers(query: query)
            results.append(contentsOf: userResults.map { user in
                SearchResult(
                    id: user.id,
                    title: user.username,
                    artist: "",
                    artworkURL: user.avatarURL?.absoluteString ?? "",
                    releaseDate: nil,
                    genre: "",
                    type: .user
                )
            })
        } catch {
            print("User search error: \(error)")
        }
        
        searchResults = results
    }
    
    private func navigateToUserProfile(userId: String) {
        isShowingUserProfile = true
        selectedUserId = userId
    }
}

struct TopAlbumCard: View {
    let album: Album
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                AsyncImage(url: album.artworkURL) { image in
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(10)
                
                Text(album.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(album.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchResultRow: View {
    let item: SearchResult
    let action: () -> Void
    @ObservedObject var viewModel: VaultViewModel
    
    var body: some View {
        Button(action: action) {
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
                        .foregroundColor(.primary)
                    Text(item.artist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let rating = viewModel.getRatingForAlbum(id: item.id) {
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SearchResult: Identifiable {
    let id: String
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
        case user
    }
}

// Add UserProfileView
struct UserProfileView: View {
    let userId: String
    @ObservedObject var viewModel: UserProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User Info
                UserInfoHeader(user: viewModel.user)
                
                // Recent Ratings
                if !viewModel.recentRatings.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Recent Ratings")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ForEach(viewModel.recentRatings) { album in
                            UserAlbumRow(album: album)
                        }
                    }
                }
                
                // User's Vault
                VStack(alignment: .leading) {
                    Text("Vault")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ForEach(viewModel.userVault) { album in
                        UserAlbumRow(album: album)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle(viewModel.user?.username ?? "Profile")
        .task {
            await viewModel.loadUserProfile(userId: userId)
        }
    }
}

struct UserInfoHeader: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: user?.avatarURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray)
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            
            Text(user?.username ?? "")
                .font(.title2)
                .bold()
            
            if let bio = user?.bio {
                Text(bio)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

struct UserAlbumRow: View {
    let album: UserAlbum
    
    var body: some View {
        HStack {
            AsyncImage(url: album.artworkURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(album.title)
                    .font(.headline)
                Text(album.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < album.rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct TopAlbumsSection: View {
    let topAlbums: [Album]
    let onAlbumSelected: (Album) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Top Albums of the Month")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 15) {
                    ForEach(topAlbums) { album in
                        TopAlbumCard(album: album) {
                            onAlbumSelected(album)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct SearchResultsSection: View {
    let results: [SearchResult]
    let spotifyService: SpotifyService
    let onAlbumSelected: (Album) -> Void
    let onUserSelected: (String) -> Void
    @ObservedObject var viewModel: VaultViewModel
    
    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(results) { item in
                SearchResultRow(item: item, action: {
                    handleItemSelection(item)
                }, viewModel: viewModel)
            }
        }
        .padding(.horizontal)
    }
    
    private func handleItemSelection(_ item: SearchResult) {
        switch item.type {
        case .song, .album:
            Task {
                if let album = try? await spotifyService.fetchAlbum(id: item.id) {
                    onAlbumSelected(album)
                }
            }
        case .user:
            onUserSelected(item.id)
        default:
            break
        }
    }
}
