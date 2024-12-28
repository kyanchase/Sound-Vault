import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                } header: {
                    Text("Appearance")
                }
                
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
                    Button("Help & Support") {
                        // Open help center
                    }
                    Button("About Sound Vault") {
                        // Show about page
                    }
                } header: {
                    Text("Support")
                }
                
                Section {
                    Button("Log Out") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    // Implement logout
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
            
            Section {
                NavigationLink("Manage Notification Types") {
                    // Detailed notification settings
                }
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
