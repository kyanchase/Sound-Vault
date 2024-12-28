import SwiftUI

struct CommentsView: View {
    @Binding var song: UserSong?
    @State private var newComment = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if let song = song {
                    List {
                        // Add your comments list here
                        Text("Comments for \(song.title)")
                    }
                    
                    HStack {
                        TextField("Add a comment...", text: $newComment)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Post") {
                            // Add comment posting logic
                        }
                    }
                    .padding()
                } else {
                    Text("No song selected")
                }
            }
            .navigationTitle("Comments")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
} 