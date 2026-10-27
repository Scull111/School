import Foundation

@MainActor
final class RideStore: ObservableObject {
    @Published var rides: [Ride] = []
    @Published var bookedRideID: UUID?
    @Published var tripLogs: [TripLog] = []
    @Published var notifications: [AppNotification] = []
    @Published var messages: [ChatMessage] = []

    private struct Snapshot: Codable {
        var rides: [Ride]
        var bookedRideID: UUID?
        var tripLogs: [TripLog]
        var notifications: [AppNotification]
        var messages: [ChatMessage]
    }
    private let url = Persistence.url("rides.json")
    private(set) var username = ""

    var bookedRide: Ride? { rides.first { $0.id == bookedRideID } }

    func load(for user: User) {
        username = user.username
        if let s = Persistence.load(Snapshot.self, from: url) {
            rides = s.rides; bookedRideID = s.bookedRideID; tripLogs = s.tripLogs
            notifications = s.notifications; messages = s.messages
        } else {
            rides = Self.sampleRides()
        }
        // Rides from earlier days are dropped; every ride must start or end at school.
        rides.removeAll {
            $0.departure < Calendar.current.startOfDay(for: .now)
                || ($0.origin != Self.school && $0.destination != Self.school)
        }
        if rides.isEmpty { rides = Self.sampleRides() }
    }

    static let school = "KIBS Hannover"

    func search(destinationContains query: String, toSchool: Bool?) -> [Ride] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        return rides
            .filter { toSchool == nil || $0.toSchool == toSchool! }
            .filter { q.isEmpty || $0.destination.lowercased().contains(q) || $0.origin.lowercased().contains(q) }
            .sorted { $0.departure < $1.departure }
    }

    func book(_ ride: Ride, as name: String) {
        guard let i = rides.firstIndex(of: ride), rides[i].freeSeats > 0, bookedRideID == nil else { return }
        rides[i].passengers.append(name)
        bookedRideID = ride.id
        notify("Fahrt gebucht",
               "\(ride.driverName) holt dich um \(ride.departure.formatted(date: .omitted, time: .shortened)) Uhr ab.")
        NotificationService.schedule(title: "Gleich geht's los",
                                     body: "Deine Fahrt mit \(ride.driverName) startet in 10 Minuten.",
                                     at: ride.departure.addingTimeInterval(-600))
        save()
    }

    func cancelBooking(as name: String) {
        guard let i = rides.firstIndex(where: { $0.id == bookedRideID }) else { return }
        rides[i].passengers.removeAll { $0 == name }
        bookedRideID = nil
        notify("Fahrt storniert", "Deine Buchung wurde storniert.")
        save()
    }

    /// Fahrt wurde beendet: Buchung entfällt, Platz bleibt belegt.
    func cancelBookingAfterRide() {
        bookedRideID = nil
        notify("Fahrt beendet", "Danke fürs Teilen! Dein CO₂-Beitrag wurde gespeichert.")
        save()
    }

    func offer(_ ride: Ride) {
        rides.append(ride)
        notify("Fahrt angeboten", "Dein Angebot für \(ride.destination) ist online.")
        save()
    }

    func logTrip(_ mode: TransportMode, km: Double, on date: Date = .now) {
        guard km > 0 else { return }
        tripLogs.append(TripLog(id: UUID(), date: date, mode: mode, distanceKm: km))
        save()
    }

    func send(_ text: String, rideID: UUID, sender: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        messages.append(ChatMessage(id: UUID(), rideID: rideID, sender: sender, text: t, date: .now))
        save()
    }

    // MARK: CO2

    /// Gespart gegenüber derselben Strecke allein im Auto.
    func savedKg(since: Date? = nil) -> Double {
        tripLogs
            .filter { since == nil || $0.date >= since! }
            .reduce(0) { $0 + $1.savedKg }
    }
    var totalKm: Double { tripLogs.reduce(0) { $0 + $1.distanceKm } }
    var avoidedCarTrips: Int { tripLogs.filter { $0.mode != .car }.count }

    // MARK: Data control

    func eraseAll() {
        tripLogs = []; notifications = []; messages = []; bookedRideID = nil
        rides = Self.sampleRides()
        Persistence.delete("rides.json")
    }

    func exportJSON() -> String {
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601; enc.outputFormatting = .prettyPrinted
        let snap = Snapshot(rides: rides, bookedRideID: bookedRideID, tripLogs: tripLogs,
                            notifications: notifications, messages: messages)
        return (try? enc.encode(snap)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    private func notify(_ title: String, _ body: String) {
        notifications.insert(AppNotification(id: UUID(), date: .now, title: title, body: body), at: 0)
    }

    private func save() {
        Persistence.save(Snapshot(rides: rides, bookedRideID: bookedRideID, tripLogs: tripLogs,
                                  notifications: notifications, messages: messages), to: url)
    }

    static func sampleRides() -> [Ride] {
        let cal = Calendar.current
        func at(_ h: Int, _ m: Int) -> Date { cal.date(bySettingHour: h, minute: m, second: 0, of: .now) ?? .now }
        return [
            Ride(id: UUID(), driverName: "Alex M.", driverVerified: true, vehicle: "VW ID.4", plate: "HN-KP 248",
                 origin: school, destination: "Hannover Südstadt", departure: at(13, 30), arrival: at(13, 52),
                 distanceKm: 6.5, seats: 4, passengers: ["Mia", "Jonas", "Lea"], price: 2.40,
                 tags: [.geteilt, .guenstig, .gruen], toSchool: false),
            Ride(id: UUID(), driverName: "Alex M.", driverVerified: true, vehicle: "VW ID.4", plate: "HN-KP 248",
                 origin: "Hannover Südstadt", destination: school, departure: at(7, 30), arrival: at(7, 52),
                 distanceKm: 6.5, seats: 4, passengers: ["Mia", "Jonas", "Lea"], price: 2.40,
                 tags: [.geteilt, .guenstig, .gruen], toSchool: true),
            Ride(id: UUID(), driverName: "Sabine W.", driverVerified: true, vehicle: "Renault Zoe", plate: "H-SW 101",
                 origin: school, destination: "Linden", departure: at(15, 20), arrival: at(15, 45),
                 distanceKm: 8, seats: 3, passengers: ["Tom"], price: 2.80, tags: [.geteilt, .elektro, .gruen],
                 toSchool: false),
            Ride(id: UUID(), driverName: "Jürgen P.", driverVerified: true, vehicle: "Skoda Octavia", plate: "H-JP 77",
                 origin: school, destination: "Döhren", departure: at(15, 30), arrival: at(15, 55),
                 distanceKm: 7, seats: 3, passengers: [], price: 3.10, tags: [.geteilt, .ruhig],
                 toSchool: false)
        ]
    }
}

extension DateFormatter {
    static let clock: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "H:mm"; return f
    }()
}
