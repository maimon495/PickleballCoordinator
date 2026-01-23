import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var content: String
    var senderID: String // Player ID
    var senderName: String
    var sentAt: Date
    var isSystemMessage: Bool

    @Relationship(deleteRule: .nullify)
    var game: Game?

    init(
        content: String,
        senderID: String,
        senderName: String,
        isSystemMessage: Bool = false
    ) {
        self.id = UUID()
        self.content = content
        self.senderID = senderID
        self.senderName = senderName
        self.sentAt = Date()
        self.isSystemMessage = isSystemMessage
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(sentAt) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(sentAt) {
            formatter.dateFormat = "'Yesterday' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }

        return formatter.string(from: sentAt)
    }

    static func systemMessage(_ content: String, for game: Game) -> ChatMessage {
        let message = ChatMessage(
            content: content,
            senderID: "system",
            senderName: "System",
            isSystemMessage: true
        )
        message.game = game
        return message
    }
}
