import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.conversations.isEmpty && !viewModel.isLoading {
                    VStack {
                        Image(systemName: "bubble.right.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No Conversations")
                            .font(.headline)
                        
                        Text("Start chatting with friends!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else if let selectedConversation = viewModel.selectedConversation {
                    ChatDetailView(
                        conversation: selectedConversation,
                        messages: viewModel.messages,
                        newMessageText: $viewModel.newMessageText,
                        onSend: viewModel.sendMessage
                    )
                } else {
                    ConversationListView(
                        conversations: viewModel.conversations,
                        onSelect: viewModel.loadMessages
                    )
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .navigationTitle("Chat")
            .onAppear {
                viewModel.loadConversations()
            }
        }
    }
}

struct ConversationListView: View {
    let conversations: [Conversation]
    let onSelect: (Conversation) -> Void
    
    var body: some View {
        List(conversations) { conversation in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.otherUserName)
                        .font(.headline)
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                }
                
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                if let time = conversation.lastMessageTime {
                    Text(time.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .onTapGesture {
                onSelect(conversation)
            }
        }
    }
}

struct ChatDetailView: View {
    let conversation: Conversation
    let messages: [Message]
    @Binding var newMessageText: String
    let onSend: () -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack(spacing: 8) {
                TextField("Type a message...", text: $newMessageText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: onSend) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(newMessageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .navigationTitle(conversation.otherUserName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(message.content)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ChatView()
}
