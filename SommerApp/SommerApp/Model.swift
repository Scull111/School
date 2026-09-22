import SwiftUI

enum Region: String, CaseIterable, Identifiable, Hashable {
    case kreta = "Kreta"
    case zuhause = "Zuhause"

    var id: String { rawValue }
}

enum Category: String, CaseIterable, Identifiable, Hashable {
    case wassersport = "Wassersport"
    case sport = "Sport"
    case ausflug = "Ausflug"
    case natur = "Natur"
    case essen = "Essen"
    case reise = "Reise"
    case zuhause = "Zuhause"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .wassersport: "water.waves"
        case .sport: "figure.run"
        case .ausflug: "sailboat"
        case .natur: "leaf"
        case .essen: "fork.knife"
        case .reise: "airplane"
        case .zuhause: "house"
        }
    }

    var tint: Color {
        switch self {
        case .wassersport: Theme.aegean
        case .sport: Color(red: 0.42, green: 0.42, blue: 0.18)
        case .ausflug: Theme.deepSea
        case .natur: Color(red: 0.25, green: 0.42, blue: 0.23)
        case .essen: Theme.clay
        case .reise: Color(red: 0.55, green: 0.23, blue: 0.35)
        case .zuhause: Theme.muted
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
    var company: String = "[MIT WEM]"
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
    case alle = "Alle"
    case kreta = "Kreta"
    case zuhause = "Zuhause"

    var id: String { rawValue }

    var region: Region? {
        switch self {
        case .alle: nil
        case .kreta: .kreta
        case .zuhause: .zuhause
        }
    }
}

enum DateText {
    static let german = Locale(identifier: "de_DE")

    static func dayMonth(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.wide).locale(german))
    }

    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.day(.twoDigits).locale(german))
    }

    static func month(_ date: Date) -> String {
        date.formatted(.dateTime.month(.wide).locale(german))
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
        sorted.filter { $0.region == .kreta }
    }

    var highlights: [Activity] {
        tripActivities.filter { $0.rating == 5 }
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
}
