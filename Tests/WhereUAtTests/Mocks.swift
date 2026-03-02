import Foundation
@testable import WhereUAt

// MARK: - Mock Authentication Service
class MockAuthService {
    private var mockUser: User?
    
    func login(email: String, password: String) async -> Bool {
        // Simulate API delay
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        guard email == "test@example.com" && password == "password123" else {
            return false
        }
        
        mockUser = User(
            id: UUID(),
            username: "testuser",
            email: email,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return true
    }
    
    func signup(email: String, password: String, username: String) async -> Bool {
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        mockUser = User(
            id: UUID(),
            username: username,
            email: email,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return true
    }
    
    func getCurrentUser() -> User? {
        return mockUser
    }
}

// MARK: - Mock Network Service
class MockNetworkService {
    private let mockVenues = [
        Venue(
            id: "venue-1",
            name: "Club Paradise",
            description: "Upscale nightclub",
            address: "123 Main St",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.7,
            category: "nightlife",
            capacity: 500,
            currentOccupancy: 350
        ),
        Venue(
            id: "venue-2",
            name: "The Lounge",
            description: "Casual bar and grill",
            address: "456 Oak Ave",
            latitude: 37.7751,
            longitude: -122.4193,
            rating: 4.2,
            category: "nightlife",
            capacity: 200,
            currentOccupancy: 120
        ),
        Venue(
            id: "venue-3",
            name: "Night Owl",
            description: "Late night jazz bar",
            address: "789 Elm St",
            latitude: 37.7748,
            longitude: -122.4195,
            rating: 4.5,
            category: "nightlife",
            capacity: 150,
            currentOccupancy: 100
        )
    ]
    
    func searchVenues(
        latitude: Double,
        longitude: Double,
        category: String
    ) async -> [Venue] {
        try? await Task.sleep(nanoseconds: 200_000_000)
        return mockVenues.filter { $0.category == category }
    }
    
    func fetchActivities(page: Int, limit: Int) async -> [Activity] {
        try? await Task.sleep(nanoseconds: 150_000_000)
        
        var activities: [Activity] = []
        let userId = UUID()
        
        for i in 0..<limit {
            activities.append(Activity(
                id: UUID(),
                userId: userId,
                userName: "Friend \(i)",
                venueId: mockVenues[i % mockVenues.count].id,
                venueName: mockVenues[i % mockVenues.count].name,
                activityType: [.checkIn, .like, .review, .rsvp][i % 4],
                timestamp: Date().addingTimeInterval(-TimeInterval(i * 3600))
            ))
        }
        
        return activities
    }
    
    func fetchConversations() async -> [Conversation] {
        try? await Task.sleep(nanoseconds: 150_000_000)
        
        return [
            Conversation(
                id: UUID(),
                otherUserId: UUID(),
                otherUserName: "John Doe",
                lastMessage: "Hey, are you going out tonight?",
                lastMessageTime: Date().addingTimeInterval(-3600),
                unreadCount: 1
            ),
            Conversation(
                id: UUID(),
                otherUserId: UUID(),
                otherUserName: "Jane Smith",
                lastMessage: "Let's meet at the club!",
                lastMessageTime: Date().addingTimeInterval(-7200),
                unreadCount: 0
            )
        ]
    }
    
    func fetchTickets() async -> [Ticket] {
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        let now = Date()
        let nextMonth = now.addingTimeInterval(86400 * 30)
        let lastMonth = now.addingTimeInterval(-86400 * 30)
        
        return [
            Ticket(
                id: UUID(),
                eventId: UUID(),
                userId: UUID(),
                ticketType: "VIP",
                price: 75.0,
                purchasedAt: now.addingTimeInterval(-86400),
                validFrom: now,
                validUntil: nextMonth,
                qrCode: "QR-VIP-001",
                status: .valid
            ),
            Ticket(
                id: UUID(),
                eventId: UUID(),
                userId: UUID(),
                ticketType: "General",
                price: 25.0,
                purchasedAt: lastMonth.addingTimeInterval(-86400),
                validFrom: lastMonth,
                validUntil: lastMonth.addingTimeInterval(86400),
                qrCode: "QR-GA-001",
                status: .used
            )
        ]
    }
}

// MARK: - Mock URLSession for Network Testing
class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw NSError(domain: "MockError", code: -1)
        }
        
        return (data, response)
    }
}

// MARK: - Test Data Generators
struct TestDataGenerator {
    static func createMockUser(id: UUID = UUID()) -> User {
        return User(
            id: id,
            username: "testuser",
            email: "test@example.com",
            bio: "Test bio",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    static func createMockVenue(id: String = "venue-test") -> Venue {
        return Venue(
            id: id,
            name: "Test Venue",
            description: "A test venue",
            address: "123 Test St",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            category: "nightlife"
        )
    }
    
    static func createMockMessage(
        senderId: UUID = UUID(),
        recipientId: UUID = UUID()
    ) -> Message {
        return Message(
            senderId: senderId,
            senderName: "TestUser",
            recipientId: recipientId,
            content: "Test message"
        )
    }
    
    static func createMockActivity(userId: UUID = UUID()) -> Activity {
        return Activity(
            id: UUID(),
            userId: userId,
            userName: "Test User",
            venueId: "venue-1",
            venueName: "Test Venue",
            activityType: .checkIn,
            timestamp: Date()
        )
    }
    
    static func createMockTicket(userId: UUID = UUID()) -> Ticket {
        let now = Date()
        return Ticket(
            id: UUID(),
            eventId: UUID(),
            userId: userId,
            ticketType: "General",
            price: 25.0,
            purchasedAt: now,
            validFrom: now,
            validUntil: now.addingTimeInterval(86400 * 30),
            qrCode: "TEST-QR-CODE",
            status: .valid
        )
    }
}
