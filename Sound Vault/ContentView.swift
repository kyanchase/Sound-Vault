//
//  ContentView.swift
//  Sound Vault
//
//  Created by Kyan Chase on 12/20/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var spotifyService = SpotifyService()
    @EnvironmentObject var vaultViewModel: VaultViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: vaultViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ExploreView(spotifyService: spotifyService, vaultViewModel: vaultViewModel)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            VaultView(viewModel: vaultViewModel)
                .tabItem {
                    Label("Vault", systemImage: "music.note.list")
                }
                .tag(2)
            
            ProfileView(viewModel: vaultViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.purple)
        .task {
            await spotifyService.requestAuthorization()
        }
    }
}

#Preview {
    ContentView()
}
