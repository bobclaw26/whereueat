import Foundation
import CoreLocation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var email: String
    var bio: String?
    var profileImageURL: URL?
    var location: String?
    var latitude: Double?
    var longitude: Double?
    var rating: Double = 0.0
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, bio, profileImageURL
        case location, latitude, longitude, rating
        case createdAt, updatedAt
    }
}

// MARK: - Venue Model
struct Venue: Codable, Identifiable {
    let id: String
    var name: String
    var description: String
    var address: String
    var latitude: Double
    var longitude: Double
    var rating: Double
    var imageURL: URL?
    var category: String
    var openingHours: String?
    var capacity: Int?
    var currentOccupancy: Int = 0
    var website: URL?
    var phone: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Friendship Model
struct Friendship: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let friendId: UUID
    let status: FriendshipStatus
    let createdAt: Date
    
    enum FriendshipStatus: String, Codable {
        case pending, accepted, blocked
    }
}

// MARK: - Message Model (24h auto-delete)
struct Message: Codable, Identifiable {
    let id: UUID
    let senderId: UUID
    let senderName: String
    let recipientId: UUID
    let content: String
    let timestamp: Date
    let expiresAt: Date // Auto-delete after 24h
    var isRead: Bool = false
    
    init(id: UUID = UUID(), senderId: UUID, senderName: String, recipientId: UUID,
         content: String, timestamp: Date = Date()) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.recipientId = recipientId
        self.content = content
        self.timestamp = timestamp
        self.expiresAt = timestamp.addingTimeInterval(86400) // 24 hours
    }
}

// MARK: - Activity Model
struct Activity: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let userName: String
    let venueId: String
    let venueName: String
    let activityType: ActivityType
    let timestamp: Date
    
    enum ActivityType: String, Codable {
        case checkIn, like, review, rsvp
    }
}

// MARK: - Going Model (event attendance)
struct Going: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let eventId: UUID
    let status: AttendanceStatus
    let registeredAt: Date
    
    enum AttendanceStatus: String, Codable {
        case going, maybe, notGoing
    }
}

// MARK: - Event Model
struct Event: Codable, Identifiable {
    let id: UUID
    let venueId: String
    let venueName: String
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var imageURL: URL?
    var attendeeCount: Int = 0
    var createdBy: UUID
    var ticketsAvailable: Int = 100
}

// MARK: - Ticket Model
struct Ticket: Codable, Identifiable {
    let id: UUID
    let eventId: UUID
    let userId: UUID
    let ticketType: String
    let price: Double
    var purchasedAt: Date?
    var validFrom: Date
    var validUntil: Date
    let qrCode: String?
    var status: TicketStatus = .valid
    
    enum TicketStatus: String, Codable {
        case valid, used, expired, refunded
    }
}

// MARK: - Transaction Model
struct Transaction: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let ticketId: UUID?
    let amount: Double
    let currency: String = "USD"
    let status: TransactionStatus
    let createdAt: Date
    let description: String?
    
    enum TransactionStatus: String, Codable {
        case pending, completed, failed, refunded
    }
}

// MARK: - Ranking/Recommendation Model
struct VenueRanking: Codable, Identifiable {
    let id: String
    let venueId: String
    let score: Double // ML-based ranking score
    let reasons: [String]
    let updatedAt: Date
}

// MARK: - Search Discovery Model
struct DiscoveryResult: Codable, Identifiable {
    let id: UUID = UUID()
    let venue: Venue
    let relevanceScore: Double
    let matchReasons: [String]
}
