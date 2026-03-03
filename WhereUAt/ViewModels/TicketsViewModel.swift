import SwiftUI
import Combine

@available(iOS 15.0, *)
@MainActor
class TicketsViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var upcomingTickets: [Ticket] = []
    @Published var pastTickets: [Ticket] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedTab = 0
    
    private let ticketService = TicketService()
    
    func loadTickets() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let allTickets = try await ticketService.fetchTickets()
                self.tickets = allTickets
                
                let now = Date()
                self.upcomingTickets = allTickets.filter { $0.validUntil > now }
                self.pastTickets = allTickets.filter { $0.validUntil <= now }
            } catch {
                self.error = "Failed to load tickets"
            }
            isLoading = false
        }
    }
    
    func refundTicket(_ ticket: Ticket) {
        Task {
            do {
                try await ticketService.refundTicket(ticket.id)
                loadTickets()
            } catch {
                self.error = "Failed to refund ticket"
            }
        }
    }
}

// MARK: - Ticket Service
class TicketService {
    private let networkService = NetworkService.shared
    private let baseURL = URL(string: "https://api.whereueat.app")!
    
    func fetchTickets() async throws -> [Ticket] {
        let url = baseURL.appendingPathComponent("/tickets")
        return try await networkService.get(from: url)
    }
    
    func purchaseTicket(eventId: UUID, ticketType: String) async throws -> Ticket {
        struct PurchaseRequest: Encodable {
            let eventId: UUID
            let ticketType: String
        }
        
        let url = baseURL.appendingPathComponent("/tickets")
        let request = PurchaseRequest(eventId: eventId, ticketType: ticketType)
        
        return try await networkService.post(to: url, body: request)
    }
    
    func refundTicket(_ ticketId: UUID) async throws {
        let url = baseURL.appendingPathComponent("/tickets/\(ticketId)/refund")
        try await networkService.post(to: url)
    }
}
