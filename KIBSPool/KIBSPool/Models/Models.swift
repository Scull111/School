import Foundation

enum Role: String, Codable { case student, parent, driver }

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    var username: String
    var displayName: String
    var role: Role
    var className: String?
    var verified: Bool
    var parentalControl: Bool
}

enum TransportMode: String, Codable, CaseIterable, Identifiable {
    case pool = "Mitfahrgelegenheit"
    case bike = "Fahrrad"
    case walk = "Zu Fuß"
    case bus = "Bus & Bahn"
    case car = "Elterntaxi"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .pool: "person.3.fill"
        case .bike: "bicycle"
        case .walk: "figure.walk"
        case .bus: "bus"
        case .car: "car.fill"
        }
    }
    /// Grobe Emission in g CO2 je Person und Fahrt (Schulweg ~5 km).
    var gramsCO2: Int {
        switch self {
        case .pool: 400
        case .bike, .walk: 0
        case .bus: 300
        case .car: 1200
        }
    }
}

enum RideTag: String, Codable, CaseIterable, Identifiable {
    case geteilt, guenstig = "günstig", gruen = "grün", elektro = "elektrisch", ruhig
    var id: String { rawValue }
}

struct Ride: Identifiable, Codable, Hashable {
    let id: UUID
    var driverName: String
    var driverVerified: Bool
    var vehicle: String
    var plate: String
    var origin: String
    var destination: String
    var departure: Date
    var arrival: Date
    var seats: Int
    var passengers: [String]
    var price: Double
    var tags: [RideTag]
    var toSchool: Bool
    var isOwn: Bool = false

    var freeSeats: Int { max(0, seats - passengers.count) }
}

struct TripLog: Identifiable, Codable {
    let id: UUID
    var date: Date
    var mode: TransportMode
}

struct AppNotification: Identifiable, Codable {
    let id: UUID
    var date: Date
    var title: String
    var body: String
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var rideID: UUID
    var sender: String
    var text: String
    var date: Date
}
