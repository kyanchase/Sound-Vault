import Foundation
import SwiftUI

@MainActor
class VaultViewModel: ObservableObject {
    @Published var savedAlbums: [Album] = []
    @Published var songOfTheDay: SongOfTheDay?
    @Published var canSetNewSong = false
    @Published var errorMessage: String?
    @Published var songOfDay: UserSong?
    @Published var wishlist: [WishlistItem] = []
    @Published var recentActivity: [UserActivity] = []
    @Published var totalSongs: Int = 0
    @Published var userSongOfDay: UserSong?
    @Published var followedUsers: [User] = []
    @Published var followingFeed: [FeedItem] = []
    @Published var botSongOfDay: FeedItem?
    @Published var currentComments: [SongComment] = []
    @Published var showingComments = false
    @Published var selectedSongForComments: FeedItem?
    @Published var recentRatings: [UserAlbum] = []
    @Published var userVault: [UserAlbum] = []
    private let recentRatingsKey = "recentRatings"
    private let savedVaultKey = "savedVault"
    
    let userService: UserService
    let spotifyService: SpotifyService
    private let defaults = UserDefaults.standard
    private let botSongKey = "botSongOfDay"
    private let botSongDateKey = "botSongDate"
    private let commentsKey = "songComments"
    
    private struct SavedBotSong: Codable {
        let id: String
        let username: String
        let userAvatarURL: String?
        let songTitle: String
        let artistName: String
        let songArtworkURL: String?
        let timestamp: String
        var isLiked: Bool
        var likeCount: Int
        var comments: [SavedComment]
        
        struct SavedComment: Codable {
            let id: String
            let text: String
            let userName: String
            let timestamp: Date
            
            func toComment() -> SongComment {
                SongComment(id: id, text: text, userName: userName, timestamp: timestamp)
            }
            
            static func from(_ comment: SongComment) -> SavedComment {
                SavedComment(id: comment.id, text: comment.text, userName: comment.userName, timestamp: comment.timestamp)
            }
        }
    }
    
    init(userService: UserService, spotifyService: SpotifyService) {
        self.userService = userService
        self.spotifyService = spotifyService
    }
    
    func loadData() async {
        // Load vault
        if let data = defaults.data(forKey: savedVaultKey),
           let decoded = try? JSONDecoder().decode([UserAlbum].self, from: data) {
            userVault = decoded
        }
        
        // Load recent ratings
        if let data = defaults.data(forKey: recentRatingsKey),
           let decoded = try? JSONDecoder().decode([UserAlbum].self, from: data) {
            recentRatings = decoded
        }
        
        // Load followed users
        followedUsers = (try? await userService.getFollowedUsers()) ?? []
        
        // Load feed
        followingFeed = await loadFollowingFeed()
        
        // Load bot's song of the day
        botSongOfDay = await loadBotSongOfDay()
    }
    
    private func loadFollowingFeed() async -> [FeedItem] {
        // TODO: Implement actual feed loading
        return []
    }
    
    private func shouldUpdateBotSong() -> Bool {
        if let lastDate = defaults.object(forKey: botSongDateKey) as? Date {
            return !Calendar.current.isDate(lastDate, inSameDayAs: Date())
        }
        return true
    }
    
    private func saveBotSong(_ feedItem: FeedItem) {
        let savedSong = SavedBotSong(
            id: feedItem.id,
            username: feedItem.username,
            userAvatarURL: feedItem.userAvatarURL?.absoluteString,
            songTitle: feedItem.songTitle,
            artistName: feedItem.artistName,
            songArtworkURL: feedItem.songArtworkURL?.absoluteString,
            timestamp: feedItem.timestamp,
            isLiked: feedItem.isLiked,
            likeCount: feedItem.likeCount,
            comments: currentComments.map { SavedBotSong.SavedComment.from($0) }
        )
        
        if let encoded = try? JSONEncoder().encode(savedSong) {
            defaults.set(encoded, forKey: botSongKey)
            defaults.set(Date(), forKey: botSongDateKey)
            self.objectWillChange.send()
        }
    }
    
    private func loadSavedBotSong() -> FeedItem? {
        guard let data = defaults.data(forKey: botSongKey),
              let savedSong = try? JSONDecoder().decode(SavedBotSong.self, from: data) else {
            return nil
        }
        
        // Load comments
        self.currentComments = savedSong.comments.map { $0.toComment() }
        
        let feedItem = FeedItem(
            id: savedSong.id,
            username: savedSong.username,
            userAvatarURL: savedSong.userAvatarURL.flatMap(URL.init),
            songTitle: savedSong.songTitle,
            artistName: savedSong.artistName,
            songArtworkURL: savedSong.songArtworkURL.flatMap(URL.init),
            timestamp: savedSong.timestamp,
            isLiked: savedSong.isLiked,
            likeCount: savedSong.likeCount,
            onLike: { [weak self] in
                if let self = self {
                    self.botSongOfDay?.isLiked.toggle()
                    self.botSongOfDay?.likeCount += self.botSongOfDay?.isLiked == true ? 1 : -1
                    if let updatedSong = self.botSongOfDay {
                        self.saveBotSong(updatedSong)
                    }
                }
            },
            onComment: { [weak self] in
                if let self = self {
                    self.selectedSongForComments = self.botSongOfDay
                    self.showingComments = true
                }
            }
        )
        return feedItem
    }
    
    private func loadBotSongOfDay() async -> FeedItem? {
        // Check if we should use cached song
        if !shouldUpdateBotSong() {
            if let savedSong = loadSavedBotSong() {
                return savedSong
            }
        }
        
        // Get new song if needed
        do {
            // Try up to 3 times to get a recommendation
            for attempt in 0..<3 {
                do {
                    let recommendations = try await spotifyService.getRecommendedSongs(limit: 1)
                    guard let recommendedSong = recommendations.first else {
                        print("No recommendations returned on attempt \(attempt + 1)")
                        if attempt < 2 {
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                        }
                        continue
                    }
                    
                    let feedItem = FeedItem(
                        id: UUID().uuidString,
                        username: "Sound Vault Bot 🤖",
                        userAvatarURL: URL(string: "https://ui-avatars.com/api/?name=Bot&background=random"),
                        songTitle: recommendedSong.title,
                        artistName: recommendedSong.artist,
                        songArtworkURL: recommendedSong.artworkURL,
                        timestamp: "Today",
                        isLiked: false,
                        likeCount: 0,
                        onLike: { [weak self] in
                            if let self = self {
                                self.botSongOfDay?.isLiked.toggle()
                                self.botSongOfDay?.likeCount += self.botSongOfDay?.isLiked == true ? 1 : -1
                                if let updatedSong = self.botSongOfDay {
                                    self.saveBotSong(updatedSong)
                                }
                            }
                        },
                        onComment: { [weak self] in
                            if let self = self {
                                self.selectedSongForComments = self.botSongOfDay
                                self.showingComments = true
                            }
                        }
                    )
                    
                    // Save the new song
                    saveBotSong(feedItem)
                    return feedItem
                } catch {
                    print("Attempt \(attempt + 1) to load bot's song failed: \(error)")
                    if attempt < 2 {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                    }
                }
            }
            
            print("Failed to load bot's song after 3 attempts")
            return nil
        } catch {
            print("Error loading bot's song: \(error)")
            return nil
        }
    }
    
    func addToWishlist(album: UserAlbum) {
        let wishlistItem = WishlistItem(
            id: UUID().uuidString,
            title: album.title,
            artist: album.artist,
            artworkURL: album.artworkURL
        )
        wishlist.append(wishlistItem)
    }
    
    func setAlbumOfDay(_ album: UserAlbum) {
        // TODO: Implement setting album of the day
    }
    
    private func addActivity(_ description: String) {
        let activity = UserActivity(
            id: UUID().uuidString,
            description: description,
            timestamp: Date(),
            artworkURL: nil
        )
        recentActivity.insert(activity, at: 0)
        
        // Keep only last 50 activities
        if recentActivity.count > 50 {
            recentActivity.removeLast()
        }
    }
    
    func toggleLike(song: UserSong) {
        if let index = followingFeed.firstIndex(where: { $0.id == song.id }) {
            followingFeed[index].isLiked.toggle()
            followingFeed[index].likeCount += followingFeed[index].isLiked ? 1 : -1
        }
        
        if userSongOfDay?.id == song.id {
            userSongOfDay?.isLiked.toggle()
            if let isLiked = userSongOfDay?.isLiked {
                userSongOfDay?.likeCount += isLiked ? 1 : -1
            }
        }
    }
    
    func shareSong(song: UserSong) {
        // TODO: Implement sharing functionality
    }
    
    func setSongOfTheDay(song: Song) async {
        // Convert Song to UserSong
        let userSong = UserSong(
            id: song.id,
            title: song.title,
            artist: song.artist,
            artworkURL: song.artworkURL,
            isLiked: false,
            likeCount: 0,
            comments: []
        )
        
        await MainActor.run {
            self.userSongOfDay = userSong
            addActivity("Set \(song.title) by \(song.artist) as Song of the Day")
        }
    }
    
    func addComment(_ text: String) {
        let comment = SongComment(text: text, userName: "You")
        currentComments.append(comment)
        if let song = botSongOfDay {
            saveBotSong(song)
        }
    }
    
    func addToVaultWithRating(album: UserAlbum) {
        // Add to vault
        if !savedAlbums.contains(where: { $0.id == album.id }) {
            let userAlbum = UserAlbum(
                id: album.id,
                title: album.title,
                artist: album.artist,
                artworkURL: album.artworkURL,
                rating: album.rating,
                dateAdded: Date()
            )
            
            // Add to vault
            userVault.append(userAlbum)
            
            // Add to recent ratings
            recentRatings.insert(userAlbum, at: 0)
            if recentRatings.count > 3 {
                recentRatings.removeLast()
            }
            
            // Save vault and ratings
            if let encoded = try? JSONEncoder().encode(userVault) {
                defaults.set(encoded, forKey: savedVaultKey)
            }
            if let encoded = try? JSONEncoder().encode(recentRatings) {
                defaults.set(encoded, forKey: recentRatingsKey)
            }
            
            addActivity("Rated \(album.title) by \(album.artist) \(album.rating) stars")
        }
    }
    
    func getRatingForAlbum(id: String) -> Int? {
        if let existingAlbum = userVault.first(where: { $0.id == id }) {
            return existingAlbum.rating
        }
        return nil
    }
}
