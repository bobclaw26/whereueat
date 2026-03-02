import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSignup = false
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                    startPoint: .topLeadingLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Logo/Header
                        VStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("WhereUAt")
                                .font(.system(size: 32, weight: .bold))
                            
                            Text("Find the hottest spots in town")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        
                        Divider()
                        
                        // Form
                        VStack(spacing: 16) {
                            if isSignup {
                                TextField("Username", text: $username)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                            }
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)
                            
                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                        
                        // Action Button
                        Button(action: handleAuth) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isSignup ? "Create Account" : "Login")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        
                        // Toggle signup/login
                        HStack(spacing: 4) {
                            Text(isSignup ? "Already have an account?" : "Don't have an account?")
                                .font(.caption)
                            
                            Button(action: { isSignup.toggle() }) {
                                Text(isSignup ? "Login" : "Sign Up")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Divider()
                        
                        // Social Login
                        VStack(spacing: 12) {
                            Text("Or continue with")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 16) {
                                SocialLoginButton(icon: "g.circle.fill", label: "Google")
                                SocialLoginButton(icon: "apple.logo", label: "Apple")
                                SocialLoginButton(icon: "f.circle.fill", label: "Facebook")
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
    
    private func handleAuth() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isSignup {
                    try await authManager.signup(
                        email: email,
                        password: password,
                        username: username
                    )
                } else {
                    try await authManager.login(
                        email: email,
                        password: password
                    )
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct SocialLoginButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.gray)
                .cornerRadius(8)
        }
    }
}

#Preview {
    LoginView(authManager: AuthManager())
}
