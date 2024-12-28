import Foundation
import SwiftUI
import MusicKit

@MainActor
class VaultViewModel: ObservableObject {
    @Published var savedAlbums: [Album] = []
    @Published var songOfTheDay: SongOfTheDay?
    @Published var canSetNewSong = false
    @Published var errorMessage: String?
    @Published var songOfDay: UserSong?
    @Published var lists: [MusicList] = []
    @Published var wishlist: [WishlistItem] = []
    @Published var recentActivity: [UserActivity] = []
    @Published var totalSongs: Int = 0
    @Published var userSongOfDay: UserSong?
    
    private let userService: UserService
    private let musicService: AppleMusicService
    let appleMusicService = AppleMusicService()
    
    init() {
        self.userService = UserService()
        self.musicService = AppleMusicService()
        loadData()
    }
    
    init(userService: UserService, musicService: AppleMusicService) {
        self.userService = userService
        self.musicService = musicService
        loadData()
    }
    
    private func loadData() {
        savedAlbums = userService.savedAlbums
        songOfTheDay = userService.songOfTheDay
        canSetNewSong = userService.canSetNewSongOfTheDay()
    }
    
    func saveAlbum(_ album: Album) {
        userService.saveAlbum(album)
        loadData()
    }
    
    func removeAlbum(_ album: Album) {
        userService.removeAlbum(album)
        loadData()
    }
    
    func isAlbumSaved(_ album: Album) -> Bool {
        return userService.isAlbumSaved(album)
    }
    
    func setSongOfTheDay(song: MusicKit.Song) async {
        guard userService.canSetNewSongOfTheDay() else {
            errorMessage = "You can only set one Song of the Day per day"
            return
        }
        
        let newSongOfTheDay = SongOfTheDay(
            songId: song.id.rawValue,
            title: song.title,
            artist: song.artistName,
            artworkURL: song.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
            date: Date(),
            comment: nil,
            likes: 0
        )
        
        userService.setSongOfTheDay(newSongOfTheDay)
        songOfTheDay = newSongOfTheDay
        canSetNewSong = false
    }
    
    // MARK: - Song of Day Methods
    func setSongOfDay(_ song: UserSong) {
        songOfDay = song
        addActivity("Set \(song.title) as Song of the Day", artworkURL: song.artworkURL)
    }
    
    func toggleLike(song: UserSong) {
        if let index = lists.flatMap({ $0.items }).firstIndex(where: { $0.id == song.id }) {
            // Toggle like status
            var updatedSong = song
            updatedSong.isLiked.toggle()
            // Update in lists
            for (listIndex, list) in lists.enumerated() {
                if let songIndex = list.items.firstIndex(where: { $0.id == song.id }) {
                    lists[listIndex].items[songIndex] = updatedSong
                }
            }
            addActivity(updatedSong.isLiked ? "Liked \(song.title)" : "Unliked \(song.title)", artworkURL: song.artworkURL)
        }
    }
    
    // MARK: - List Methods
    func createList(name: String) {
        let newList = MusicList(name: name)
        lists.append(newList)
        addActivity("Created new list: \(name)", artworkURL: nil)
    }
    
    func addToList(song: UserSong, list: MusicList) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }) else { return }
        if !lists[listIndex].items.contains(where: { $0.id == song.id }) {
            lists[listIndex].items.append(song)
            addActivity("Added \(song.title) to \(list.name)", artworkURL: song.artworkURL)
        }
    }
    
    // MARK: - Wishlist Methods
    func addToWishlist(song: UserSong) {
        let wishlistItem = WishlistItem(title: song.title, artist: song.artist, artworkURL: song.artworkURL)
        if !wishlist.contains(where: { $0.id == wishlistItem.id }) {
            wishlist.append(wishlistItem)
            addActivity("Added \(song.title) to wishlist", artworkURL: song.artworkURL)
        }
    }
    
    // MARK: - Activity Methods
    private func addActivity(_ description: String, artworkURL: URL?) {
        let activity = UserActivity(description: description, artworkURL: artworkURL)
        recentActivity.insert(activity, at: 0)
        
        // Keep only last 50 activities
        if recentActivity.count > 50 {
            recentActivity.removeLast()
        }
    }
    
    // MARK: - Helper Methods
    func shareSong(song: UserSong) {
        // Implement sharing functionality
        addActivity("Shared \(song.title)", artworkURL: song.artworkURL)
    }
    
    // MARK: - MusicKit Conversion
    func convertToUserSong(_ musicKitSong: MusicKit.Song) -> UserSong {
        UserSong(
            title: musicKitSong.title,
            artist: musicKitSong.artistName,
            artworkURL: musicKitSong.artwork?.url(width: 300, height: 300),
            isLiked: false
        )
    }
    
    func setSongOfTheDay(song: Song) async {
        do {
            // Convert MusicKit Song to UserSong
            let userSong = UserSong(
                id: song.id.rawValue,
                title: song.title,
                artist: song.artistName,
                artworkURL: song.artwork?.url(width: 300, height: 300),
                comment: nil,
                likes: 0,
                date: Date(),
                isLiked: false
            )
            
            await MainActor.run {
                self.userSongOfDay = userSong
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
