import XCTest
@testable import WhereUAt

final class WhereUAtUnitTests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testUserModelCreation() {
        let user = User(
            id: UUID(),
            username: "testuser",
            email: "test@example.com",
            bio: "Test bio",
            profileImageURL: nil,
            location: "San Francisco, CA",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.rating, 0.0)
    }
    
    func testVenueModelCreation() {
        let venue = Venue(
            id: "test-venue-1",
            name: "Test Club",
            description: "A great nightclub",
            address: "123 Main St",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            imageURL: nil,
            category: "nightlife",
            openingHours: "10PM - 4AM",
            capacity: 500,
            currentOccupancy: 250
        )
        
        XCTAssertEqual(venue.name, "Test Club")
        XCTAssertEqual(venue.rating, 4.5)
        XCTAssertEqual(venue.currentOccupancy, 250)
        XCTAssert(venue.currentOccupancy < venue.capacity!)
    }
    
    func testMessageAutoDeleteExpiration() {
        let now = Date()
        let message = Message(
            senderId: UUID(),
            senderName: "TestUser",
            recipientId: UUID(),
            content: "Test message",
            timestamp: now
        )
        
        // Message should expire 24 hours from creation
        let expectedExpiration = now.addingTimeInterval(86400)
        let timeDifference = abs(message.expiresAt.timeIntervalSince(expectedExpiration))
        XCTAssert(timeDifference < 1.0) // Within 1 second
    }
    
    func testFriendshipModel() {
        let userId = UUID()
        let friendId = UUID()
        
        let friendship = Friendship(
            id: UUID(),
            userId: userId,
            friendId: friendId,
            status: .pending,
            createdAt: Date()
        )
        
        XCTAssertEqual(friendship.status, .pending)
        XCTAssertEqual(friendship.userId, userId)
        XCTAssertEqual(friendship.friendId, friendId)
    }
    
    func testActivityModel() {
        let userId = UUID()
        let activity = Activity(
            id: UUID(),
            userId: userId,
            userName: "John",
            venueId: "venue-1",
            venueName: "Club Paradise",
            activityType: .checkIn,
            timestamp: Date()
        )
        
        XCTAssertEqual(activity.userName, "John")
        XCTAssertEqual(activity.activityType, .checkIn)
    }
    
    func testTicketModel() {
        let now = Date()
        let ticket = Ticket(
            id: UUID(),
            eventId: UUID(),
            userId: UUID(),
            ticketType: "General Admission",
            price: 25.0,
            purchasedAt: now,
            validFrom: now,
            validUntil: now.addingTimeInterval(86400),
            qrCode: "QR123456",
            status: .valid
        )
        
        XCTAssertEqual(ticket.price, 25.0)
        XCTAssertEqual(ticket.status, .valid)
        XCTAssertNotNil(ticket.qrCode)
    }
    
    func testTransactionModel() {
        let transaction = Transaction(
            id: UUID(),
            userId: UUID(),
            ticketId: UUID(),
            amount: 50.0,
            status: .completed,
            createdAt: Date(),
            description: "Ticket purchase"
        )
        
        XCTAssertEqual(transaction.amount, 50.0)
        XCTAssertEqual(transaction.status, .completed)
        XCTAssertEqual(transaction.currency, "USD")
    }
    
    // MARK: - Enum Tests
    
    func testFriendshipStatusEnums() {
        let statuses: [Friendship.FriendshipStatus] = [.pending, .accepted, .blocked]
        XCTAssertEqual(statuses.count, 3)
    }
    
    func testActivityTypeEnums() {
        let types: [Activity.ActivityType] = [.checkIn, .like, .review, .rsvp]
        XCTAssertEqual(types.count, 4)
    }
    
    func testTicketStatusEnums() {
        let statuses: [Ticket.TicketStatus] = [.valid, .used, .expired, .refunded]
        XCTAssertEqual(statuses.count, 4)
    }
    
    func testTransactionStatusEnums() {
        let statuses: [Transaction.TransactionStatus] = [.pending, .completed, .failed, .refunded]
        XCTAssertEqual(statuses.count, 4)
    }
    
    // MARK: - Encoding/Decoding Tests
    
    func testUserCoding() throws {
        let user = User(
            id: UUID(),
            username: "testuser",
            email: "test@example.com",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let encoded = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: encoded)
        
        XCTAssertEqual(decoded.username, user.username)
        XCTAssertEqual(decoded.email, user.email)
    }
    
    func testVenueCoding() throws {
        let venue = Venue(
            id: "test-venue",
            name: "Test Venue",
            description: "Test Description",
            address: "Test Address",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            category: "nightlife"
        )
        
        let encoded = try JSONEncoder().encode(venue)
        let decoded = try JSONDecoder().decode(Venue.self, from: encoded)
        
        XCTAssertEqual(decoded.name, venue.name)
        XCTAssertEqual(decoded.latitude, venue.latitude)
    }
    
    // MARK: - Validation Tests
    
    func testVenueOccupancyValidation() {
        let venue = Venue(
            id: "venue-1",
            name: "Club",
            description: "Test",
            address: "123 Main",
            latitude: 37.7749,
            longitude: -122.4194,
            rating: 4.5,
            category: "nightlife",
            capacity: 100,
            currentOccupancy: 80
        )
        
        XCTAssert(venue.currentOccupancy < venue.capacity!)
    }
    
    func testTicketValidation() {
        let now = Date()
        let expiredTicket = Ticket(
            id: UUID(),
            eventId: UUID(),
            userId: UUID(),
            ticketType: "GA",
            price: 25.0,
            validFrom: now.addingTimeInterval(-86400),
            validUntil: now.addingTimeInterval(-3600),
            qrCode: nil,
            status: .expired
        )
        
        XCTAssertTrue(now > expiredTicket.validUntil)
        XCTAssertEqual(expiredTicket.status, .expired)
    }
}
