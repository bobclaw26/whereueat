import SwiftUI

@main
struct WhereUAtApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var mapViewModel = MapViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                TabView {
                    MapView(viewModel: mapViewModel)
                        .tabItem {
                            Label("Map", systemImage: "map")
                        }
                    
                    FriendsFeedView()
                        .tabItem {
                            Label("Feed", systemImage: "person.2")
                        }
                    
                    ChatView()
                        .tabItem {
                            Label("Chat", systemImage: "bubble.right")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                    
                    TicketsView()
                        .tabItem {
                            Label("Tickets", systemImage: "ticket")
                        }
                }
            } else {
                LoginView(authManager: authManager)
            }
        }
    }
}
