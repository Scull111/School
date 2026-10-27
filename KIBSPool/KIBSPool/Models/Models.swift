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
    case walk = "Zu Fuß"
    case bike = "Fahrrad"
    case scooter = "E-Scooter"
    case bus = "Bus"
    case train = "Bahn"
    case pool = "Mitfahrgelegenheit"
    case car = "Elterntaxi"
    var id: String { rawValue }

    /// Referenz für „gespart“: allein im Auto.
    static let baselineGramsPerKm = 170.0

    var symbol: String {
        switch self {
        case .pool: "person.3.fill"
        case .bike: "bicycle"
        case .walk: "figure.walk"
        case .scooter: "scooter"
        case .bus: "bus"
        case .train: "tram.fill"
        case .car: "car.fill"
        }
    }
    /// Grobe Emission in g CO₂ je Person und Kilometer.
    var gramsPerKm: Double {
        switch self {
        case .walk, .bike: 0
        case .scooter: 20
        case .train: 40
        case .pool: 60
        case .bus: 80
        case .car: 170
        }
    }

    /// Gespartes CO₂ in kg gegenüber einer Einzelfahrt im Auto.
    func savedKg(km: Double) -> Double {
        max(0, Self.baselineGramsPerKm - gramsPerKm) * km / 1000
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
    var distanceKm: Double
    var seats: Int
    var passengers: [String]
    var price: Double
    var tags: [RideTag]
    /// Jede Fahrt hat die Schule als Start (Rückfahrt) oder als Ziel (Hinfahrt).
    var toSchool: Bool
    var isOwn: Bool = false

    var freeSeats: Int { max(0, seats - passengers.count) }
}

struct TripLog: Identifiable, Codable {
    let id: UUID
    var date: Date
    var mode: TransportMode
    var distanceKm: Double

    var savedKg: Double { mode.savedKg(km: distanceKm) }
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
