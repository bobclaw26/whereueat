import SwiftUI

struct FriendsFeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.activities.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 16) {
                        Image(systemImage: "person.2.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No Activity Yet")
                            .font(.headline)
                        
                        Text("Follow friends to see their activities!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.activities) { activity in
                            ActivityFeedItemView(activity: activity) {
                                viewModel.likeActivity(activity)
                            }
                        }
                        
                        if viewModel.hasMoreData {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .onAppear {
                                viewModel.loadMoreActivities()
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Friends Feed")
            .refreshable {
                viewModel.loadActivities()
            }
        }
    }
}

struct ActivityFeedItemView: View {
    let activity: Activity
    let onLike: () -> Void
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(activity.userName.prefix(1))
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.userName)
                        .font(.headline)
                    
                    Text(activity.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Activity description
            HStack(spacing: 4) {
                Image(systemName: activityIcon)
                    .foregroundColor(.blue)
                
                Text(activityText)
                    .font(.body)
            }
            
            // Venue tag
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                
                Text(activity.venueName)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            // Actions
            HStack(spacing: 20) {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                        Text("Like")
                    }
                    .font(.caption)
                    .foregroundColor(isLiked ? .red : .gray)
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                        Text("Reply")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    var activityIcon: String {
        switch activity.activityType {
        case .checkIn: return "location.fill"
        case .like: return "heart.fill"
        case .review: return "star.fill"
        case .rsvp: return "calendar.circle.fill"
        }
    }
    
    var activityText: String {
        switch activity.activityType {
        case .checkIn: return "checked in"
        case .like: return "liked a venue"
        case .review: return "left a review"
        case .rsvp: return "is going to an event"
        }
    }
}

#Preview {
    FriendsFeedView()
}
