import SwiftUI
import Combine

@available(iOS 15.0, *)
@MainActor
class ChatViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var selectedConversation: Conversation?
    @Published var messages: [Message] = []
    @Published var newMessageText = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private let chatService = ChatService()
    private var messageRefreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadConversations()
        startMessageRefresh()
    }
    
    func loadConversations() {
        isLoading = true
        Task {
            do {
                self.conversations = try await chatService.fetchConversations()
            } catch {
                self.error = "Failed to load conversations"
            }
            isLoading = false
        }
    }
    
    func loadMessages(for conversation: Conversation) {
        selectedConversation = conversation
        Task {
            do {
                self.messages = try await chatService.fetchMessages(conversationId: conversation.id)
            } catch {
                self.error = "Failed to load messages"
            }
        }
    }
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty,
              let conversation = selectedConversation else { return }
        
        let message = Message(
            id: UUID(),
            senderId: UUID(), // Current user ID
            senderName: "You",
            recipientId: conversation.otherUserId,
            content: newMessageText
        )
        
        Task {
            do {
                try await chatService.sendMessage(message, to: conversation.id)
                messages.append(message)
                newMessageText = ""
            } catch {
                self.error = "Failed to send message"
            }
        }
    }
    
    private func startMessageRefresh() {
        messageRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                if let conversation = self?.selectedConversation {
                    self?.loadMessages(for: conversation)
                }
            }
        }
    }
    
    deinit {
        messageRefreshTimer?.invalidate()
    }
}

// MARK: - Supporting Models
struct Conversation: Identifiable {
    let id: UUID
    let otherUserId: UUID
    let otherUserName: String
    let lastMessage: String?
    let lastMessageTime: Date?
    var unreadCount: Int = 0
}
