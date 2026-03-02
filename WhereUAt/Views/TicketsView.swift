import SwiftUI

struct TicketsView: View {
    @StateObject private var viewModel = TicketsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.tickets.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No Tickets Yet")
                            .font(.headline)
                        
                        Text("Purchase tickets to events!")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: Text("Browse Events")) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Browse Events")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    TabView(selection: $viewModel.selectedTab) {
                        // Upcoming Tickets
                        VStack {
                            if viewModel.upcomingTickets.isEmpty {
                                Text("No upcoming tickets")
                                    .foregroundColor(.gray)
                            } else {
                                List(viewModel.upcomingTickets) { ticket in
                                    UpcomingTicketRowView(ticket: ticket)
                                }
                                .listStyle(.plain)
                            }
                        }
                        .tag(0)
                        
                        // Past Tickets
                        VStack {
                            if viewModel.pastTickets.isEmpty {
                                Text("No past tickets")
                                    .foregroundColor(.gray)
                            } else {
                                List(viewModel.pastTickets) { ticket in
                                    PastTicketRowView(ticket: ticket)
                                }
                                .listStyle(.plain)
                            }
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Tickets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewModel.loadTickets() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.loadTickets()
            }
        }
    }
}

struct UpcomingTicketRowView: View {
    let ticket: Ticket
    @State private var showQRCode = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with event info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ticket Type: \(ticket.ticketType)")
                        .font(.headline)
                    
                    Text("Valid until \(ticket.validUntil.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("$\(ticket.price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            // Status Badge
            HStack {
                Label(ticket.status.rawValue.capitalized, systemImage: statusIcon)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .cornerRadius(6)
                
                Spacer()
                
                Button(action: { showQRCode = true }) {
                    Label("Show Code", systemImage: "qrcode")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .sheet(isPresented: $showQRCode) {
            QRCodeView(qrCode: ticket.qrCode ?? "")
        }
    }
    
    var statusIcon: String {
        switch ticket.status {
        case .valid: return "checkmark.circle.fill"
        case .used: return "checkmark.circle.fill"
        case .expired: return "xmark.circle.fill"
        case .refunded: return "return"
        }
    }
    
    var statusColor: Color {
        switch ticket.status {
        case .valid: return .green
        case .used: return .blue
        case .expired: return .red
        case .refunded: return .orange
        }
    }
}

struct PastTicketRowView: View {
    let ticket: Ticket
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.ticketType)
                        .font(.headline)
                    
                    if let purchased = ticket.purchasedAt {
                        Text("Purchased \(purchased.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Label(ticket.status.rawValue.capitalized, systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct QRCodeView: View {
    let qrCode: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Scan at Entry")
                        .font(.headline)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Text(qrCode)
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                    
                    Text("Show this code to the staff")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitle("Event Ticket", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TicketsView()
}
