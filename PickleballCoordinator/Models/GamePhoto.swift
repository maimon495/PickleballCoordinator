import Foundation
import SwiftData

@Model
final class GamePhoto {
    var id: UUID
    var imageData: Data?
    var caption: String
    var uploaderID: String // Player ID
    var uploaderName: String
    var uploadedAt: Date

    @Relationship(deleteRule: .nullify)
    var game: Game?

    init(
        imageData: Data? = nil,
        caption: String = "",
        uploaderID: String,
        uploaderName: String
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.caption = caption
        self.uploaderID = uploaderID
        self.uploaderName = uploaderName
        self.uploadedAt = Date()
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: uploadedAt)
    }
}
