import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Account Settings") {
                        AccountSettingsView()
                    }
                    NavigationLink("Notifications") {
                        NotificationSettingsView()
                    }
                    NavigationLink("Privacy") {
                        PrivacySettingsView()
                    }
                } header: {
                    Text("App Settings")
                }
                
                Section {
                    NavigationLink("Help & Support") {
                        HelpSupportView()
                    }
                    NavigationLink("About") {
                        AboutView()
                    }
                } header: {
                    Text("More")
                }
                
                Section {
                    Button("Log Out", role: .destructive) {
                        showingLogoutAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    // TODO: Implement logout
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

struct AccountSettingsView: View {
    @State private var email = "user@example.com"
    @State private var username = "username"
    
    var body: some View {
        Form {
            Section(header: Text("Profile Information")) {
                TextField("Username", text: $username)
                TextField("Email", text: $email)
            }
            
            Section {
                Button("Change Password") {
                    // Implement password change
                }
                Button("Delete Account") {
                    // Implement account deletion
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = true
    @State private var dailySongAlert = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Push Notifications", isOn: $pushEnabled)
                Toggle("Email Notifications", isOn: $emailEnabled)
                Toggle("Daily Song Alert", isOn: $dailySongAlert)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacySettingsView: View {
    @State private var isProfilePublic = true
    @State private var showListeningActivity = true
    
    var body: some View {
        Form {
            Section(header: Text("Profile Privacy")) {
                Toggle("Public Profile", isOn: $isProfilePublic)
                Toggle("Show Listening Activity", isOn: $showListeningActivity)
            }
            
            Section {
                Button("Privacy Policy") {
                    // Show privacy policy
                }
                Button("Terms of Service") {
                    // Show terms of service
                }
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpSupportView: View {
    var body: some View {
        List {
            Section(header: Text("Frequently Asked Questions")) {
                NavigationLink("How to use Sound Vault?") {
                    FAQDetailView(
                        title: "How to use Sound Vault?",
                        content: """
                        Sound Vault is your personal music diary and social platform. Here's how to get started:
                        
                        1. Daily Song: Share one song each day that represents your mood or current favorite
                        2. Vault: Save albums you love and rate them
                        3. Explore: Discover new music and connect with other users
                        4. Profile: Track your music journey and see your stats
                        
                        Interact with other users by following them, liking their songs, and commenting on their posts.
                        """
                    )
                }
                
                NavigationLink("How to add songs?") {
                    FAQDetailView(
                        title: "How to add songs?",
                        content: """
                        You can add songs in several ways:
                        
                        1. Daily Song: Tap the + button on the Home screen
                        2. Vault: Use the Add to Vault button in Explore
                        3. Search: Use the search bar in Explore to find specific songs
                        
                        All songs are sourced from Spotify for the best quality and legal compliance.
                        """
                    )
                }
                
                NavigationLink("Account & Privacy") {
                    FAQDetailView(
                        title: "Account & Privacy",
                        content: """
                        Your privacy is important to us. Here's what you should know:
                        
                        1. Profile Privacy: Control who can see your activity
                        2. Data Usage: We only store necessary information
                        3. Music Data: Sourced from Spotify
                        4. Account Security: Use strong passwords and enable 2FA
                        
                        Check our Privacy Policy for more details.
                        """
                    )
                }
            }
            
            Section(header: Text("Contact Us")) {
                Link("Email Support", destination: URL(string: "mailto:support@soundvault.app")!)
                Link("Twitter", destination: URL(string: "https://twitter.com/soundvault")!)
                Link("Instagram", destination: URL(string: "https://instagram.com/soundvault")!)
            }
            
            Section(header: Text("Legal")) {
                NavigationLink("Terms of Service") {
                    LegalDocumentView(title: "Terms of Service", content: termsOfService)
                }
                NavigationLink("Privacy Policy") {
                    LegalDocumentView(title: "Privacy Policy", content: privacyPolicy)
                }
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 20) {
                    Image("app_icon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    
                    Text("Sound Vault")
                        .font(.title)
                        .bold()
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            Section(header: Text("About")) {
                Text("""
                    Sound Vault is your personal music diary and social platform. Share your daily soundtrack, discover new music, and connect with others through the universal language of music.
                    
                    Created with love for music lovers, by music lovers. Our mission is to help people discover and share the music that moves them.
                    """)
                    .padding(.vertical, 8)
            }
            
            Section(header: Text("Credits")) {
                Text("Powered by Apple Music")
                Text("Designed and developed in San Francisco")
                Text("© 2024 Sound Vault. All rights reserved.")
            }
            
            Section(header: Text("Connect")) {
                Link("Website", destination: URL(string: "https://soundvault.app")!)
                Link("Twitter", destination: URL(string: "https://twitter.com/soundvault")!)
                Link("Instagram", destination: URL(string: "https://instagram.com/soundvault")!)
            }
        }
        .navigationTitle("About Sound Vault")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQDetailView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            Text(content)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LegalDocumentView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            Text(content)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Legal content
let termsOfService = """
Terms of Service

1. Acceptance of Terms
By accessing and using Sound Vault, you agree to these terms.

2. Service Description
Sound Vault is a music sharing and discovery platform.

3. User Accounts
- You must maintain accurate account information
- You are responsible for account security
- Minimum age requirement is 13 years

4. Content Guidelines
- Respect copyright laws
- No harmful or inappropriate content
- We reserve the right to remove content

5. Privacy
Your privacy is protected under our Privacy Policy.

6. Termination
We may terminate accounts for violations.

7. Changes to Terms
Terms may be updated with notice.

8. Contact
Questions? Contact support@soundvault.app
"""

let privacyPolicy = """
Privacy Policy

1. Information Collection
- Account information
- Music preferences
- Usage data

2. Information Usage
- Personalize experience
- Improve service
- Communication

3. Data Protection
- Industry-standard security
- Regular audits
- Encrypted storage

4. User Rights
- Access your data
- Request deletion
- Update information

5. Third-Party Services
- Apple Music integration
- Analytics tools

6. Updates to Policy
Policy may be updated with notice.

7. Contact
Privacy questions? Contact privacy@soundvault.app
"""
