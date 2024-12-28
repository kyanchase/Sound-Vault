import SwiftUI

struct CommentsView: View {
    let song: Song?
    @State private var newComment = ""
    @Environment(\.dismiss) private var dismiss
    @State private var comments: [Comment] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(comments) { comment in
                        CommentRow(comment: comment)
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
        let comment = Comment(
            id: UUID(),
            text: newComment,
            userName: "Current User",
            timestamp: Date()
        )
        comments.append(comment)
        newComment = ""
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.userName)
                    .font(.headline)
                Spacer()
                Text(comment.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.text)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

struct Comment: Identifiable {
    let id: UUID
    let text: String
    let userName: String
    let timestamp: Date
}
