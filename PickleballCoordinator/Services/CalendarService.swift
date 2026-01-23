import Foundation
import EventKit

class CalendarService {
    static let shared = CalendarService()

    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Permission

    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToEvents()
            } else {
                return try await eventStore.requestAccess(to: .event)
            }
        } catch {
            print("Calendar access error: \(error)")
            return false
        }
    }

    var hasAccess: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    // MARK: - Add Game to Calendar

    func addGameToCalendar(_ game: Game) async throws -> String? {
        guard let confirmedDate = game.confirmedDate else {
            throw CalendarError.noConfirmedDate
        }

        if !hasAccess {
            let granted = await requestAccess()
            guard granted else {
                throw CalendarError.accessDenied
            }
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = "Pickleball: \(game.displayTitle)"
        event.startDate = confirmedDate
        event.endDate = confirmedDate.addingTimeInterval(90 * 60) // 90 minutes default duration

        // Add location if available
        if let court = game.court {
            event.location = court.address
            event.structuredLocation = EKStructuredLocation(title: court.name)
            if let coordinate = court.coordinate {
                event.structuredLocation?.geoLocation = CLLocation(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            }
        }

        // Add notes
        var notes = game.notes
        if let players = game.players, !players.isEmpty {
            notes += "\n\nPlayers:\n"
            notes += players.map { "• \($0.name)" }.joined(separator: "\n")
        }
        event.notes = notes

        // Add reminder 1 hour before
        event.addAlarm(EKAlarm(relativeOffset: -3600))

        event.calendar = eventStore.defaultCalendarForNewEvents

        try eventStore.save(event, span: .thisEvent)

        return event.eventIdentifier
    }

    // MARK: - Remove Game from Calendar

    func removeGameFromCalendar(eventIdentifier: String) throws {
        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
            return
        }

        try eventStore.remove(event, span: .thisEvent)
    }

    // MARK: - Check for Conflicts

    func checkForConflicts(at date: Date, duration: TimeInterval = 90 * 60) -> [EKEvent] {
        guard hasAccess else { return [] }

        let endDate = date.addingTimeInterval(duration)
        let predicate = eventStore.predicateForEvents(
            withStart: date,
            end: endDate,
            calendars: nil
        )

        return eventStore.events(matching: predicate)
    }

    // MARK: - Find Available Times

    func findAvailableTimes(
        on date: Date,
        startHour: Int = 6,
        endHour: Int = 22,
        slotDuration: TimeInterval = 90 * 60
    ) -> [Date] {
        guard hasAccess else { return [] }

        var availableTimes: [Date] = []
        let calendar = Calendar.current

        var currentTime = calendar.date(
            bySettingHour: startHour,
            minute: 0,
            second: 0,
            of: date
        ) ?? date

        let dayEnd = calendar.date(
            bySettingHour: endHour,
            minute: 0,
            second: 0,
            of: date
        ) ?? date

        while currentTime < dayEnd {
            let conflicts = checkForConflicts(at: currentTime, duration: slotDuration)
            if conflicts.isEmpty {
                availableTimes.append(currentTime)
            }
            currentTime = currentTime.addingTimeInterval(30 * 60) // 30 minute intervals
        }

        return availableTimes
    }
}

enum CalendarError: LocalizedError {
    case accessDenied
    case noConfirmedDate
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar access was denied. Please enable it in Settings."
        case .noConfirmedDate:
            return "The game doesn't have a confirmed date yet."
        case .saveFailed:
            return "Failed to save the event to your calendar."
        }
    }
}
