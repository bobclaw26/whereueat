import SwiftUI
import Combine

@available(iOS 15.0, *)
@MainActor
class FeedViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var hasMoreData = true
    
    private let feedService = FeedService()
    private var currentPage = 0
    private let pageSize = 20
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadActivities()
    }
    
    func loadActivities() {
        isLoading = true
        error = nil
        currentPage = 0
        
        Task {
            do {
                self.activities = try await feedService.fetchFriendsActivities(
                    page: currentPage,
                    pageSize: pageSize
                )
            } catch {
                self.error = "Failed to load activities"
            }
            isLoading = false
        }
    }
    
    func loadMoreActivities() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        currentPage += 1
        
        Task {
            do {
                let moreActivities = try await feedService.fetchFriendsActivities(
                    page: currentPage,
                    pageSize: pageSize
                )
                
                if moreActivities.isEmpty {
                    self.hasMoreData = false
                } else {
                    self.activities.append(contentsOf: moreActivities)
                }
            } catch {
                self.error = "Failed to load more activities"
                currentPage -= 1
            }
            isLoading = false
        }
    }
    
    func likeActivity(_ activity: Activity) {
        Task {
            do {
                try await feedService.likeActivity(activity.id)
            } catch {
                self.error = "Failed to like activity"
            }
        }
    }
}
