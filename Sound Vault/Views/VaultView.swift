import SwiftUI

struct VaultView: View {
    @ObservedObject var viewModel: VaultViewModel
    @State private var selectedSegment = 0
    @State private var showExplore = false
    private let segments = ["Albums", "Lists", "Wishlist"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Custom Segmented Control
                Picker("Category", selection: $selectedSegment) {
                    ForEach(0..<3) { index in
                        Text(segments[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected segment
                TabView(selection: $selectedSegment) {
                    AlbumsGridView(viewModel: viewModel)
                        .tag(0)
                    
                    ListsView(viewModel: viewModel)
                        .tag(1)
                    
                    WishlistView(viewModel: viewModel)
                        .tag(2)
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
                ExploreView(appleMusicService: viewModel.appleMusicService, vaultViewModel: viewModel)
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
            if viewModel.savedAlbums.isEmpty {
                EmptyVaultView()
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.savedAlbums) { album in
                        VaultAlbumCard(album: album, viewModel: viewModel)
                    }
                }
                .padding()
            }
        }
    }
}

struct VaultAlbumCard: View {
    let album: Album
    @ObservedObject var viewModel: VaultViewModel
    
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
        }
    }
}

struct ListsView: View {
    @ObservedObject var viewModel: VaultViewModel
    @State private var showCreateList = false
    
    var body: some View {
        VStack {
            if viewModel.lists.isEmpty {
                VStack(spacing: 20) {
                    Text("No Lists Yet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showCreateList = true }) {
                        Label("Create List", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.lists) { list in
                            ListCard(list: list)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showCreateList) {
            CreateListView(viewModel: viewModel)
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

struct ListCard: View {
    let list: MusicList
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if list.items.isEmpty {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                        ForEach(list.items.prefix(4)) { item in
                            if let url = item.artworkURL {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                            } else {
                                Color.gray.opacity(0.3)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .aspectRatio(1.0, contentMode: .fit)
            
            Text(list.name)
                .font(.headline)
                .lineLimit(1)
            
            Text("\(list.items.count) items")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
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
            ExploreView(appleMusicService: viewModel.appleMusicService, vaultViewModel: viewModel)
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

struct CreateListView: View {
    @ObservedObject var viewModel: VaultViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var listName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("List Name", text: $listName)
                }
            }
            .navigationTitle("Create List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        viewModel.createList(name: listName)
                        dismiss()
                    }
                    .disabled(listName.isEmpty)
                }
            }
        }
    }
}
