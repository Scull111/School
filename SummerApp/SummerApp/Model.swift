import SwiftUI

enum Region: String, CaseIterable, Identifiable, Hashable {
    case crete = "Crete"
    case home = "Home"

    var id: String { rawValue }
}

enum Category: String, CaseIterable, Identifiable, Hashable {
    case watersports = "Watersports"
    case sport = "Sport"
    case dayTrip = "Day trip"
    case nature = "Nature"
    case food = "Food"
    case travel = "Travel"
    case home = "Home"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .watersports: "water.waves"
        case .sport: "figure.run"
        case .dayTrip: "sailboat"
        case .nature: "leaf"
        case .food: "fork.knife"
        case .travel: "airplane"
        case .home: "house"
        }
    }

    var tint: Color {
        switch self {
        case .watersports: Theme.aegean
        case .sport: Color(red: 0.42, green: 0.42, blue: 0.18)
        case .dayTrip: Theme.deepSea
        case .nature: Color(red: 0.25, green: 0.42, blue: 0.23)
        case .food: Theme.clay
        case .travel: Color(red: 0.55, green: 0.23, blue: 0.35)
        case .home: Theme.muted
        }
    }
}

struct Activity: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var place: String
    var date: Date
    var category: Category
    var region: Region
    var rating: Int
    var note: String
    var duration: String = ""
    var weather: String = ""
    var company: String = ""
    var photos: [Data] = []

    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Trip: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var destination: String
    var start: Date
    var end: Date
    var note: String

    var dayCount: Int {
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        return days + 1
    }

    var dateRange: String {
        "\(DateText.dayMonth(start)) – \(DateText.dayMonth(end))"
    }
}

struct MonthGroup: Identifiable {
    var name: String
    var activities: [Activity]

    var id: String { name }
}

enum TimelineFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case crete = "Crete"
    case home = "Home"

    var id: String { rawValue }

    var region: Region? {
        switch self {
        case .all: nil
        case .crete: .crete
        case .home: .home
        }
    }
}

enum DateText {
    static let english = Locale(identifier: "en_US")

    static func dayMonth(_ date: Date) -> String {
        date.formatted(.dateTime.month(.wide).day().locale(english))
    }

    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.day(.twoDigits).locale(english))
    }

    static func month(_ date: Date) -> String {
        date.formatted(.dateTime.month(.wide).locale(english))
    }
}

@Observable
final class SummerStore {
    var trip: Trip
    var activities: [Activity]

    init(trip: Trip, activities: [Activity]) {
        self.trip = trip
        self.activities = activities
    }

    var sorted: [Activity] {
        activities.sorted { $0.date < $1.date }
    }

    var recent: [Activity] {
        Array(sorted.reversed().prefix(4))
    }

    var favourite: Activity? {
        sorted.max { $0.rating < $1.rating }
    }

    var placeCount: Int {
        Set(activities.map(\.place)).count
    }

    var tripActivities: [Activity] {
        sorted.filter { $0.region == .crete }
    }

    var highlights: [Activity] {
        tripActivities.filter { $0.rating == 5 }
    }

    var tripPhotos: [Data] {
        tripActivities.flatMap(\.photos)
    }

    func current(_ activity: Activity) -> Activity? {
        activities.first { $0.id == activity.id }
    }

    func activities(in region: Region?) -> [Activity] {
        guard let region else { return sorted }
        return sorted.filter { $0.region == region }
    }

    func monthGroups(in region: Region?) -> [MonthGroup] {
        var groups: [MonthGroup] = []
        for activity in activities(in: region) {
            let name = DateText.month(activity.date)
            if groups.last?.name == name {
                groups[groups.count - 1].activities.append(activity)
            } else {
                groups.append(MonthGroup(name: name, activities: [activity]))
            }
        }
        return groups
    }

    func add(_ activity: Activity) {
        activities.append(activity)
    }

    func update(_ activity: Activity) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        activities[index] = activity
    }

    func delete(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
    }
}
