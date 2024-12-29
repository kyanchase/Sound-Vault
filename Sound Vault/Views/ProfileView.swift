import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: VaultViewModel
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeader()
                    
                    // Song of the Day
                    if let songOfDay = viewModel.songOfDay {
                        VStack(alignment: .leading) {
                            Text("Today's Song")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            SongCard(song: songOfDay)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Stats
                    StatsView(viewModel: viewModel)
                    
                    // Recent Activity
                    RecentActivityView(viewModel: viewModel)
                }
                .padding(.top)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("Username")
                .font(.title2)
                .bold()
            
            Text("@username")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct StatsView: View {
    @ObservedObject var viewModel: VaultViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Stats")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            HStack {
                StatCard(title: "Songs", value: "\(viewModel.totalSongs)")
                StatCard(title: "Following", value: "\(viewModel.followedUsers.count)")
            }
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct SongCard: View {
    let song: UserSong
    
    var body: some View {
        HStack {
            AsyncImage(url: song.artworkURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                Text(song.artist)
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

struct RecentActivityView: View {
    @ObservedObject var viewModel: VaultViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Activity")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Text("\(viewModel.recentActivity.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if viewModel.recentActivity.isEmpty {
                Text("No recent activity")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.recentActivity) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
}

struct ActivityRow: View {
    let activity: UserActivity
    
    var body: some View {
        HStack(spacing: 15) {
            if let artworkURL = activity.artworkURL {
                AsyncImage(url: artworkURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 50, height: 50)
                .cornerRadius(10)
            } else {
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.purple.opacity(0.8))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let userService = UserService()
        let placeholder = VaultViewModel(userService: userService, spotifyService: SpotifyService())
        ProfileView(viewModel: placeholder)
            .task {
                await placeholder.loadData()
            }
    }
}
#endif
