import SwiftUI

struct MainTabView: View {
    @StateObject private var spotifyService = SpotifyService()
    @State private var vaultViewModel: VaultViewModel?
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if let viewModel = vaultViewModel {
                TabView(selection: $selectedTab) {
                    HomeView(viewModel: viewModel)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    ExploreView(spotifyService: spotifyService, vaultViewModel: viewModel)
                        .tabItem {
                            Label("Explore", systemImage: "magnifyingglass")
                        }
                        .tag(1)
                    
                    VaultView(viewModel: viewModel)
                        .tabItem {
                            Label("Vault", systemImage: "archivebox.fill")
                        }
                        .tag(2)
                    
                    ProfileView(viewModel: viewModel)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(3)
                }
                .tint(.purple)
            } else {
                ProgressView("Loading...")
                    .task {
                        let userService = UserService()
                        await userService.initialize()
                        let vm = VaultViewModel(userService: userService, spotifyService: spotifyService)
                        await vm.loadData()
                        vaultViewModel = vm
                    }
            }
        }
        .task {
            await spotifyService.requestAuthorization()
        }
    }
}

#Preview {
    MainTabView()
}
