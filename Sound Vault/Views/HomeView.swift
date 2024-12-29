import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: VaultViewModel
    @State private var showingSongPicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Song of the Day Section
                    SongOfTheDayCard(viewModel: viewModel, showingSongPicker: $showingSongPicker)

                    // Bot's Song of the Day
                    BotSongOfTheDayCard(viewModel: viewModel)

                    // Following Feed
                    if !viewModel.followedUsers.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Following Feed")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            ForEach(viewModel.followingFeed) { feedItem in
                                FeedItemCard(feedItem: feedItem)
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingSongPicker) {
                SongPickerView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct SongOfTheDayCard: View {
    @ObservedObject var viewModel: VaultViewModel
    @Binding var showingSongPicker: Bool
    @State private var showComments = false
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Your Song of the Day")
                .font(.headline)
            
            if let userSongOfDay = viewModel.userSongOfDay {
                VStack(spacing: 12) {
                    AsyncImage(url: userSongOfDay.artworkURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                    
                    Text(userSongOfDay.title)
                        .font(.title3)
                        .bold()
                    
                    Text(userSongOfDay.artist)
                        .foregroundColor(.secondary)
                    
                    // Social interaction buttons
                    HStack(spacing: 30) {
                        Button(action: { viewModel.toggleLike(song: userSongOfDay) }) {
                            HStack {
                                Image(systemName: userSongOfDay.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(userSongOfDay.isLiked ? .red : .primary)
                                Text("\(userSongOfDay.likeCount)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: { showComments.toggle() }) {
                            Image(systemName: "bubble.right")
                        }
                    }
                    .font(.title2)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
            } else {
                Button(action: { showingSongPicker = true }) {
                    VStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                        Text("Add Today's Song")
                            .font(.headline)
                    }
                    .foregroundColor(.accentColor)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showComments) {
            CommentsView(song: $viewModel.userSongOfDay)
        }
    }
}

struct SongRow: View {
    let song: Song
    
    var body: some View {
        HStack {
            if let artworkURL = song.artworkURL {
                AsyncImage(url: artworkURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 60, height: 60)
                .cornerRadius(6)
            }
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct BotSongOfTheDayCard: View {
    @ObservedObject var viewModel: VaultViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Songs of the Day")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            if let botSong = viewModel.botSongOfDay {
                FeedItemCard(feedItem: botSong)
            } else {
                VStack(spacing: 10) {
                    ProgressView()
                        .padding()
                    Text("Loading recommendation...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 2)
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $viewModel.showingComments) {
            BotCommentsView(viewModel: viewModel)
        }
    }
}

struct FeedItemCard: View {
    @ObservedObject var feedItem: FeedItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: feedItem.userAvatarURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(feedItem.username)
                        .font(.headline)
                    Text(feedItem.timestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Album/Song Preview
            HStack {
                AsyncImage(url: feedItem.songArtworkURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(feedItem.songTitle)
                        .font(.headline)
                    Text(feedItem.artistName)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            
            // Interaction Buttons
            HStack {
                Button(action: { feedItem.onLike() }) {
                    HStack {
                        Label("Like", systemImage: feedItem.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(feedItem.isLiked ? .red : .purple)
                        Text("\(feedItem.likeCount)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: { feedItem.onComment() }) {
                    Label("Comment", systemImage: "message")
                }
                
                if let onShare = feedItem.onShare {
                    Spacer()
                    Button(action: onShare) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .foregroundColor(.purple)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
