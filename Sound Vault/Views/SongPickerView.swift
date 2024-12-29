import SwiftUI

struct SongPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VaultViewModel
    @State private var searchText = ""
    @State private var searchResults: [Song] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .onChange(of: searchText) { oldValue, newValue in
                        searchSongs()
                    }
                
                if isSearching {
                    ProgressView()
                } else {
                    List(searchResults) { song in
                        SongRow(song: song)
                            .onTapGesture {
                                Task {
                                    await viewModel.setSongOfTheDay(song: song)
                                    dismiss()
                                }
                            }
                    }
                }
            }
            .navigationTitle("Pick a Song")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func searchSongs() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        Task {
            do {
                searchResults = try await viewModel.spotifyService.searchSongs(query: searchText)
                isSearching = false
            } catch {
                await MainActor.run {
                    viewModel.errorMessage = error.localizedDescription
                    isSearching = false
                }
            }
        }
    }
} 