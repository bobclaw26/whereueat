import Foundation
import Combine

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case userNotFound
    case userExists
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network error occurred"
        case .userNotFound:
            return "User not found"
        case .userExists:
            return "User already exists"
        }
    }
}

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let userDefaults = UserDefaults.standard
    private let authService = AuthService()
    
    init() {
        // Check if user is logged in from previous session
        if let savedUserData = userDefaults.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: savedUserData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let user = try await authService.login(email: email, password: password)
        self.currentUser = user
        self.isAuthenticated = true
        
        // Save user to UserDefaults
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: "currentUser")
        }
    }
    
    func signup(email: String, password: String, username: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let user = try await authService.signup(
            email: email,
            password: password,
            username: username
        )
        self.currentUser = user
        self.isAuthenticated = true
        
        // Save user to UserDefaults
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: "currentUser")
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        userDefaults.removeObject(forKey: "currentUser")
    }
    
    func updateProfile(_ user: User) async throws {
        self.currentUser = try await authService.updateProfile(user)
        
        // Update saved user
        if let userData = try? JSONEncoder().encode(currentUser) {
            userDefaults.set(userData, forKey: "currentUser")
        }
    }
}
