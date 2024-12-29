import SwiftUI

struct BotCommentsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VaultViewModel
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if let song = viewModel.selectedSongForComments {
                    List {
                        Section(header: Text("Song Info")) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(song.songTitle)
                                    .font(.headline)
                                Text(song.artistName)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("Comments")) {
                            ForEach(viewModel.currentComments) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(comment.userName)
                                            .font(.headline)
                                        Spacer()
                                        Text(comment.timestamp, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(comment.text)
                                }
                                .padding(.vertical, 4)
                            }
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
        viewModel.addComment(newComment)
        newComment = ""
    }
} 