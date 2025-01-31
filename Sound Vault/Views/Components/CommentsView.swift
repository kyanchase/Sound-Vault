import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var song: UserSong?
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if let song = song {
                    List {
                        Section(header: Text("Song Info")) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(song.title)
                                    .font(.headline)
                                Text(song.artist)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("Comments")) {
                            Text("Comments coming soon...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Comment input field
                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: submitComment) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.accentColor)
                    }
                    .disabled(newComment.isEmpty)
                    .padding(.trailing)
                }
                .padding(.bottom)
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submitComment() {
        guard !newComment.isEmpty else { return }
        // TODO: Implement comment functionality for user songs
        newComment = ""
    }
}
