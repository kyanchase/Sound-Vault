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
                StatCard(title: "Lists", value: "\(viewModel.lists.count)")
                StatCard(title: "Following", value: "0")
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
            Text("Recent Activity")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            ForEach(viewModel.recentActivity) { activity in
                ActivityRow(activity: activity)
            }
        }
    }
}

struct ActivityRow: View {
    let activity: UserActivity
    
    var body: some View {
        HStack {
            AsyncImage(url: activity.artworkURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 40, height: 40)
            .cornerRadius(6)
            
            VStack(alignment: .leading) {
                Text(activity.description)
                    .font(.subheadline)
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: VaultViewModel())
    }
}
