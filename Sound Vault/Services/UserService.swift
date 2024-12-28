import Foundation
import SwiftUI

@MainActor
class UserService: ObservableObject {
    @Published var currentUser: User?
    @Published var savedAlbums: [Album] = []
    @Published var songOfTheDay: SongOfTheDay?
    
    private let defaults = UserDefaults.standard
    private let savedAlbumsKey = "savedAlbums"
    private let songOfTheDayKey = "songOfTheDay"
    
    init() {
        loadSavedAlbums()
        loadSongOfTheDay()
        
        // Mock user for development
        currentUser = User(
            id: "user123",
            username: "MusicLover",
            followers: [],
            following: [],
            albumLists: [],
            likedAlbums: []
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
    
    func isAlbumSaved(_ album: Album) -> Bool {
        return savedAlbums.contains(where: { $0.id == album.id })
    }
    
    func setSongOfTheDay(_ song: SongOfTheDay) {
        songOfTheDay = song
        saveSongOfTheDayToDisk()
    }
    
    func canSetNewSongOfTheDay() -> Bool {
        guard let lastSongDate = songOfTheDay?.date else { return true }
        return !Calendar.current.isDate(lastSongDate, inSameDayAs: Date())
    }
    
    private func loadSavedAlbums() {
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
    
    private func loadSongOfTheDay() {
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
}
