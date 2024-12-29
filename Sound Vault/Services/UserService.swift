import Foundation
import SwiftUI

actor UserService {
    private var currentUser: User?
    private var savedAlbums: [Album] = []
    private var songOfTheDay: SongOfTheDay?
    
    private let defaults = UserDefaults.standard
    private let savedAlbumsKey = "savedAlbums"
    private let songOfTheDayKey = "songOfTheDay"
    
    init() {
        // Move initialization to a separate async method
        // This init should remain empty
    }
    
    func initialize() async {
        await loadSavedAlbums()
        await loadSongOfTheDay()
        setMockUser() // Remove await since this is not async
    }
    
    private func setMockUser() {
        currentUser = User(
            id: "user123",
            username: "MusicLover",
            avatarURL: nil,
            bio: "Music enthusiast",
            email: "user@example.com",
            isFollowing: false,
            followersCount: 0,
            followingCount: 0,
            vaultCount: 0
        )
    }
    
    func saveAlbum(_ album: Album) {
        if !savedAlbums.contains(where: { $0.id == album.id }) {
            savedAlbums.append(album)
            saveToDisk()
        }
    }
    
    func removeAlbum(_ album: Album) {
        savedAlbums.removeAll(where: { $0.id == album.id })
        saveToDisk()
    }
    
    nonisolated func isAlbumSaved(_ album: Album) async -> Bool {
        await savedAlbums.contains(where: { $0.id == album.id })
    }
    
    func setSongOfTheDay(_ song: SongOfTheDay) {
        songOfTheDay = song
        saveSongOfTheDayToDisk()
    }
    
    nonisolated func canSetNewSongOfTheDay() async -> Bool {
        if let lastSongDate = await songOfTheDay?.date {
            return !Calendar.current.isDate(lastSongDate, inSameDayAs: Date())
        }
        return true
    }
    
    private func loadSavedAlbums() async {
        if let data = defaults.data(forKey: savedAlbumsKey),
           let decoded = try? JSONDecoder().decode([Album].self, from: data) {
            savedAlbums = decoded
        }
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedAlbums) {
            defaults.set(encoded, forKey: savedAlbumsKey)
        }
    }
    
    private func loadSongOfTheDay() async {
        if let data = defaults.data(forKey: songOfTheDayKey),
           let decoded = try? JSONDecoder().decode(SongOfTheDay.self, from: data) {
            songOfTheDay = decoded
        }
    }
    
    private func saveSongOfTheDayToDisk() {
        if let encoded = try? JSONEncoder().encode(songOfTheDay) {
            defaults.set(encoded, forKey: songOfTheDayKey)
        }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        // TODO: Implement actual API call
        return []
    }
    
    func fetchUserProfile(userId: String) async throws -> (User, [UserAlbum], [UserAlbum]) {
        // TODO: Implement actual API call
        let user = User(
            id: userId,
            username: "User \(userId)",
            avatarURL: nil,
            bio: "Music lover",
            email: "user@example.com",
            isFollowing: false,
            followersCount: 0,
            followingCount: 0,
            vaultCount: 0
        )
        
        // For now, return empty arrays for vault and ratings
        return (user, [], [])
    }
    
    func followUser(userId: String) async throws {
        // TODO: Implement actual API call
    }
    
    func unfollowUser(userId: String) async throws {
        // TODO: Implement actual API call
    }
    
    func getFollowedUsers() async throws -> [User] {
        // TODO: Implement actual API call
        return []
    }
}
