import SwiftUI

struct VaultView: View {
    @ObservedObject var viewModel: VaultViewModel
    @State private var selectedSegment = 0
    @State private var showExplore = false
    private let segments = ["Albums", "Wishlist"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Custom Segmented Control
                Picker("Category", selection: $selectedSegment) {
                    ForEach(0..<2) { index in
                        Text(segments[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected segment
                TabView(selection: $selectedSegment) {
                    AlbumsGridView(viewModel: viewModel)
                        .tag(0)
                    
                    WishlistView(viewModel: viewModel)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Your Vault")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showExplore = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showExplore) {
                ExploreView(spotifyService: viewModel.spotifyService, vaultViewModel: viewModel)
            }
        }
    }
}

struct AlbumsGridView: View {
    @ObservedObject var viewModel: VaultViewModel
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            if viewModel.userVault.isEmpty {
                EmptyVaultView()
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.userVault) { album in
                        VaultAlbumCard(album: album)
                    }
                }
                .padding()
            }
        }
    }
}

struct VaultAlbumCard: View {
    let album: UserAlbum
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if let url = album.artworkURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                } else {
                    Color.gray
                }
            }
            .aspectRatio(1.0, contentMode: .fit)
            .cornerRadius(8)
            
            Text(album.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(album.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            HStack {
                ForEach(0..<5) { index in
                    Image(systemName: index < album.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                }
            }
        }
    }
}

struct EmptyVaultView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your Vault is Empty")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Add some music to get started!")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct WishlistView: View {
    @ObservedObject var viewModel: VaultViewModel
    @State private var showExplore = false
    
    var body: some View {
        VStack {
            if viewModel.wishlist.isEmpty {
                VStack(spacing: 20) {
                    Text("Your Wishlist is Empty")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showExplore = true }) {
                        Label("Add to Wishlist", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.wishlist) { item in
                            WishlistItemCard(item: item)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showExplore) {
            ExploreView(spotifyService: viewModel.spotifyService, vaultViewModel: viewModel)
        }
    }
}

struct WishlistItemCard: View {
    let item: WishlistItem
    
    var body: some View {
        HStack {
            if let url = item.artworkURL {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                Color.gray
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
