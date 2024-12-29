import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @ObservedObject var viewModel: VaultViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 0
    @State private var showingRatingPrompt = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Album Artwork
                    AsyncImage(url: album.artworkURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Album Info
                    VStack(spacing: 8) {
                        Text(album.title)
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text(album.artist)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text(album.releaseDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !album.genre.isEmpty {
                            Text(album.genre)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Add to Vault Button
                    Button(action: {
                        showingRatingPrompt = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add to Vault")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .sheet(isPresented: $showingRatingPrompt) {
            RatingView(rating: $rating) { selectedRating in
                let userAlbum = UserAlbum(from: album, rating: selectedRating)
                viewModel.addToVaultWithRating(album: userAlbum)
                dismiss()
            }
        }
    }
}

struct RatingView: View {
    @Binding var rating: Int
    let onRatingSelected: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Rate this Album")
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    rating = index
                                }
                            }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Button(action: {
                    onRatingSelected(rating)
                }) {
                    Text("Confirm")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(rating == 0 ? Color.gray : Color.purple)
                        .cornerRadius(15)
                }
                .disabled(rating == 0)
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
} 