import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = viewModel.user {
                        // Profile Header
                        VStack(spacing: 16) {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(user.username.prefix(1).uppercased())
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.blue)
                                )
                            
                            Text(user.username)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if let bio = user.bio {
                                Text(bio)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Stats
                            HStack(spacing: 30) {
                                StatView(
                                    label: "Rating",
                                    value: String(format: "%.1f", user.rating),
                                    icon: "star.fill"
                                )
                                
                                StatView(
                                    label: "Checkins",
                                    value: "\(viewModel.checkinCount)",
                                    icon: "mappin"
                                )
                                
                                StatView(
                                    label: "Friends",
                                    value: "\(viewModel.friendsCount)",
                                    icon: "person.2"
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding()
                        
                        // Edit Profile Button
                        Button(action: { viewModel.isEditingProfile = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.horizontal)
                        
                        // Recent Activities
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Activities")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if viewModel.recentActivities.isEmpty {
                                Text("No recent activities")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(viewModel.recentActivities) { activity in
                                    RecentActivityItemView(activity: activity)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Settings")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            NavigationLink(destination: Text("Preferences")) {
                                HStack {
                                    Image(systemName: "gear")
                                        .foregroundColor(.blue)
                                    Text("Preferences")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            
                            Button(action: viewModel.logout) {
                                HStack {
                                    Image(systemName: "arrow.backward.circle")
                                        .foregroundColor(.red)
                                    Text("Logout")
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                    } else if viewModel.isLoading {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.loadProfile()
            }
            .sheet(isPresented: $viewModel.isEditingProfile) {
                EditProfileView(user: $viewModel.user)
            }
        }
    }
}

struct StatView: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

struct RecentActivityItemView: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.venueName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(activity.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct EditProfileView: View {
    @Binding var user: User?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username = ""
    @State private var bio = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    TextField("Username", text: $username)
                    TextField("Bio", text: $bio)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save changes
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
