import Foundation
import SwiftData
import CoreLocation

@Model
final class Court {
    var id: UUID
    var name: String
    var address: String
    var latitude: Double?
    var longitude: Double?
    var numberOfCourts: Int
    var isIndoor: Bool
    var hasLights: Bool
    var notes: String
    var isFavorite: Bool
    var createdAt: Date

    // Surface type
    var surfaceType: CourtSurface

    init(
        name: String,
        address: String = "",
        numberOfCourts: Int = 1,
        isIndoor: Bool = false,
        hasLights: Bool = false,
        surfaceType: CourtSurface = .concrete,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.numberOfCourts = numberOfCourts
        self.isIndoor = isIndoor
        self.hasLights = hasLights
        self.surfaceType = surfaceType
        self.notes = notes
        self.isFavorite = false
        self.createdAt = Date()
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var mapsURL: URL? {
        let query = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?q=\(query)")
    }

    var displayDetails: String {
        var details: [String] = []
        if numberOfCourts > 1 {
            details.append("\(numberOfCourts) courts")
        }
        if isIndoor {
            details.append("Indoor")
        }
        if hasLights {
            details.append("Lights")
        }
        details.append(surfaceType.displayName)
        return details.joined(separator: " · ")
    }
}

enum CourtSurface: String, Codable, CaseIterable {
    case concrete
    case asphalt
    case sport_court // Sport Court brand surface
    case wood
    case other

    var displayName: String {
        switch self {
        case .concrete: return "Concrete"
        case .asphalt: return "Asphalt"
        case .sport_court: return "Sport Court"
        case .wood: return "Wood"
        case .other: return "Other"
        }
    }
}
