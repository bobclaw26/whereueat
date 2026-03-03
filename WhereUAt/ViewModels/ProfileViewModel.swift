import SwiftUI
import Combine

@available(iOS 15.0, *)
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var recentActivities: [Activity] = []
    @Published var isLoading = false
    @Published var isEditingProfile = false
    @Published var error: String?
    @Published var checkinCount = 0
    @Published var friendsCount = 0
    
    private let authManager = AuthManager()
    
    init() {
        // Load initial user from auth manager
        self.user = authManager.currentUser
    }
    
    func loadProfile() {
        isLoading = true
        
        Task {
            do {
                // In a real app, this would fetch from the API
                self.recentActivities = generateMockActivities()
                self.checkinCount = 15
                self.friendsCount = 42
            } catch {
                self.error = "Failed to load profile"
            }
            isLoading = false
        }
    }
    
    func logout() {
        authManager.logout()
    }
    
    private func generateMockActivities() -> [Activity] {
        return [
            Activity(
                id: UUID(),
                userId: UUID(),
                userName: user?.username ?? "User",
                venueId: "venue1",
                venueName: "Club Paradise",
                activityType: .checkIn,
                timestamp: Date().addingTimeInterval(-3600)
            ),
            Activity(
                id: UUID(),
                userId: UUID(),
                userName: user?.username ?? "User",
                venueId: "venue2",
                venueName: "The Lounge",
                activityType: .like,
                timestamp: Date().addingTimeInterval(-7200)
            ),
            Activity(
                id: UUID(),
                userId: UUID(),
                userName: user?.username ?? "User",
                venueId: "venue3",
                venueName: "Night Owl Bar",
                activityType: .review,
                timestamp: Date().addingTimeInterval(-10800)
            )
        ]
    }
}
