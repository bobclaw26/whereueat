import Foundation

// MARK: - Authentication Service
class AuthService {
    private let networkService = NetworkService.shared
    private let baseURL = URL(string: "https://api.whereueat.app")!
    
    func login(email: String, password: String) async throws -> User {
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }
        
        let request = LoginRequest(email: email, password: password)
        let url = baseURL.appendingPathComponent("/auth/login")
        
        return try await networkService.post(to: url, body: request)
    }
    
    func signup(email: String, password: String, username: String) async throws -> User {
        struct SignupRequest: Encodable {
            let email: String
            let password: String
            let username: String
        }
        
        let request = SignupRequest(email: email, password: password, username: username)
        let url = baseURL.appendingPathComponent("/auth/signup")
        
        return try await networkService.post(to: url, body: request)
    }
    
    func updateProfile(_ user: User) async throws -> User {
        let url = baseURL.appendingPathComponent("/users/\(user.id)")
        return try await networkService.put(to: url, body: user)
    }
}

// MARK: - Foursquare Service
class FoursquareService {
    private let networkService = NetworkService.shared
    private let apiKey = ProcessInfo.processInfo.environment["FOURSQUARE_API_KEY"] ?? ""
    private let baseURL = URL(string: "https://api.foursquare.com/v3")!
    
    func searchVenues(
        latitude: Double,
        longitude: Double,
        category: String,
        radiusKm: Double = 5.0
    ) async throws -> [Venue] {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "radius", value: "\(Int(radiusKm * 1000))"),
            URLQueryItem(name: "categories", value: category),
            URLQueryItem(name: "limit", value: "50")
        ]
        
        guard var url = components.url else {
            throw NetworkError.invalidURL
        }
        url = baseURL.appendingPathComponent("/places/search").appendingQueryItems(components.queryItems ?? [])
        
        let headers = ["Authorization": apiKey]
        
        struct FoursquareResponse: Decodable {
            let results: [FoursquareVenue]
        }
        
        let response: FoursquareResponse = try await networkService.get(from: url, headers: headers)
        
        return response.results.map { result in
            Venue(
                id: result.fsqId,
                name: result.name,
                description: result.categories?.first?.name ?? "",
                address: result.location?.formattedAddress ?? "",
                latitude: result.location?.latitude ?? 0,
                longitude: result.location?.longitude ?? 0,
                rating: result.rating ?? 0,
                category: category,
                openingHours: nil,
                capacity: nil
            )
        }
    }
}

struct FoursquareVenue: Decodable {
    let fsqId: String
    let name: String
    let location: Location?
    let rating: Double?
    let categories: [Category]?
    
    struct Location: Decodable {
        let latitude: Double
        let longitude: Double
        let formattedAddress: String
    }
    
    struct Category: Decodable {
        let name: String
    }
}

// MARK: - Chat Service
class ChatService {
    private let networkService = NetworkService.shared
    private let baseURL = URL(string: "https://api.whereueat.app")!
    
    func fetchConversations() async throws -> [Conversation] {
        let url = baseURL.appendingPathComponent("/chat/conversations")
        return try await networkService.get(from: url)
    }
    
    func fetchMessages(conversationId: UUID) async throws -> [Message] {
        let url = baseURL.appendingPathComponent("/chat/conversations/\(conversationId)/messages")
        return try await networkService.get(from: url)
    }
    
    func sendMessage(_ message: Message, to conversationId: UUID) async throws {
        let url = baseURL.appendingPathComponent("/chat/conversations/\(conversationId)/messages")
        
        struct MessageRequest: Encodable {
            let content: String
            let senderId: UUID
        }
        
        let request = MessageRequest(content: message.content, senderId: message.senderId)
        let _: [String: String] = try await networkService.post(to: url, body: request)
    }
}

// MARK: - Feed Service
class FeedService {
    private let networkService = NetworkService.shared
    private let baseURL = URL(string: "https://api.whereueat.app")!
    
    func fetchFriendsActivities(page: Int, pageSize: Int) async throws -> [Activity] {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(pageSize)")
        ]
        
        guard var url = components.url else {
            throw NetworkError.invalidURL
        }
        url = baseURL.appendingPathComponent("/activities/feed")
        
        return try await networkService.get(from: url)
    }
    
    func likeActivity(_ activityId: UUID) async throws {
        let url = baseURL.appendingPathComponent("/activities/\(activityId)/like")
        let _: [String: String] = try await networkService.post(to: url)
    }
}

// MARK: - Square Payments Service
class SquarePaymentsService {
    private let networkService = NetworkService.shared
    private let squareAPIKey = ProcessInfo.processInfo.environment["SQUARE_API_KEY"] ?? ""
    private let baseURL = URL(string: "https://connect.squareup.com/v2")!
    
    func createPayment(
        amount: Int,
        currency: String,
        sourceId: String,
        description: String
    ) async throws -> Transaction {
        struct PaymentRequest: Encodable {
            let sourceId: String
            let amount: Int
            let currency: String
            let description: String
        }
        
        let request = PaymentRequest(
            sourceId: sourceId,
            amount: amount,
            currency: currency,
            description: description
        )
        
        let url = baseURL.appendingPathComponent("/payments")
        let headers = ["Authorization": "Bearer \(squareAPIKey)"]
        
        return try await networkService.post(to: url, body: request, headers: headers)
    }
}

// MARK: - URL Extension
extension URL {
    func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        return components?.url ?? self
    }
}
