import SwiftUI
import MusicKit

struct HomeView: View {
    @ObservedObject var viewModel: VaultViewModel
    @State private var showingSongPicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Song of the Day Section
                    SongOfTheDayCard(viewModel: viewModel, showingSongPicker: $showingSongPicker)

                    // Following Feed
                    VStack(alignment: .leading) {
                        Text("Following Feed")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)

                        ForEach(0..<5) { _ in
                            FeedItemCard()
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
    @State private var comment = ""
    
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
                            Image(systemName: userSongOfDay.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(userSongOfDay.isLiked ? .red : .primary)
                        }
                        
                        Button(action: { showComments.toggle() }) {
                            Image(systemName: "bubble.right")
                        }
                        
                        Button(action: { viewModel.shareSong(song: userSongOfDay) }) {
                            Image(systemName: "square.and.arrow.up")
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
        //.sheet(isPresented: $showComments) {
            //CommentsView(song: $viewModel.userSongOfDay)
        }
    }




struct SongRow: View {
    let song: MusicKit.Song
    
    var body: some View {
        HStack {
            if let artwork = song.artwork {
                AsyncImage(url: artwork.url(width: 60, height: 60)) { image in
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
                Text(song.artistName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FeedItemCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text("Username")
                        .font(.headline)
                    Text("2 hours ago")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Album/Song Preview
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading) {
                    Text("Song Title")
                        .font(.headline)
                    Text("Artist Name")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            
            // Interaction Buttons
            HStack {
                Button(action: {}) {
                    Label("Like", systemImage: "heart")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Label("Comment", systemImage: "message")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .foregroundColor(.purple)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
