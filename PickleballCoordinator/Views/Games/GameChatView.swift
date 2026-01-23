import SwiftUI
import SwiftData

struct GameChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var game: Game

    @State private var messageText = ""
    @State private var currentUserID = UUID().uuidString // In a real app, this would be the logged-in user

    var messages: [ChatMessage] {
        (game.messages ?? []).sorted { $0.sentAt < $1.sentAt }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(
                                    message: message,
                                    isCurrentUser: message.senderID == currentUserID
                                )
                                .id(message.id)
                            }
                        }
                        .padding(PickleballTheme.pageMargin)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Message Input
                messageInput
            }
            .pickleballBackground()
            .navigationTitle("Game Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(PickleballTheme.courtGreen)
                }
            }
        }
    }

    private var messageInput: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $messageText, axis: .vertical)
                .font(PickleballTheme.body)
                .padding(12)
                .background(PickleballTheme.cream)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .lineLimit(1...5)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        messageText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? PickleballTheme.inkMuted
                        : PickleballTheme.courtGreen
                    )
            }
            .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, PickleballTheme.pageMargin)
        .padding(.vertical, 12)
        .background(PickleballTheme.warmWhite)
    }

    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }

        let message = ChatMessage(
            content: trimmedText,
            senderID: currentUserID,
            senderName: "You" // In a real app, this would be the user's name
        )
        message.game = game

        if game.messages == nil {
            game.messages = []
        }
        game.messages?.append(message)

        messageText = ""
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser && !message.isSystemMessage {
                    Text(message.senderName)
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)
                }

                if message.isSystemMessage {
                    // System message style
                    Text(message.content)
                        .font(PickleballTheme.caption)
                        .foregroundStyle(PickleballTheme.inkMuted)
                        .italic()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(PickleballTheme.parchment.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text(message.content)
                        .font(PickleballTheme.body)
                        .foregroundStyle(isCurrentUser ? PickleballTheme.cream : PickleballTheme.inkNavy)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            isCurrentUser
                            ? PickleballTheme.courtGreen
                            : PickleballTheme.cream
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                Text(message.formattedTime)
                    .font(.system(size: 10))
                    .foregroundStyle(PickleballTheme.inkMuted.opacity(0.7))
            }

            if !isCurrentUser { Spacer(minLength: 60) }
        }
    }
}

#Preview {
    GameChatView(game: Game())
        .modelContainer(for: [Game.self, ChatMessage.self], inMemory: true)
}
