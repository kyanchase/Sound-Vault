import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var userVault: [UserAlbum] = []
    @Published var recentRatings: [UserAlbum] = []
    @Published var errorMessage: String?
    
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func loadUserProfile(userId: String) async {
        do {
            let (user, vault, ratings) = try await userService.fetchUserProfile(userId: userId)
            await MainActor.run {
                self.user = user
                self.userVault = vault
                self.recentRatings = ratings
            }
        } catch {
            errorMessage = "Failed to load user profile: \(error.localizedDescription)"
        }
    }
    
    func followUser() async {
        guard let user = user else { return }
        do {
            try await userService.followUser(userId: user.id)
            self.user?.isFollowing = true
        } catch {
            errorMessage = "Failed to follow user: \(error.localizedDescription)"
        }
    }
    
    func unfollowUser() async {
        guard let user = user else { return }
        do {
            try await userService.unfollowUser(userId: user.id)
            self.user?.isFollowing = false
        } catch {
            errorMessage = "Failed to unfollow user: \(error.localizedDescription)"
        }
    }
} 