import Foundation

struct Activity: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var place: String
    var date: Date
    var category: Category
    var region: Region
    var rating: Int
    var note: String
    var duration = ""
    var weather = ""
    var photos: [Data] = []
}

enum Category: String, CaseIterable, Codable {
    case watersports = "Watersports"
    case sport = "Sport"
    case dayTrip = "Day trip"
    case nature = "Nature"
    case food = "Food"
    case travel = "Travel"
    case home = "Home"

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
}

enum Region: String, CaseIterable, Codable {
    case crete = "Crete"
    case home = "Home"
}

enum Filter: String, CaseIterable {
    case all = "All"
    case crete = "Crete"
    case home = "Home"

    var region: Region? {
        switch self {
        case .all: nil
        case .crete: .crete
        case .home: .home
        }
    }
}

extension Date {
    private static let english = Locale(identifier: "en_US")

    var monthName: String {
        formatted(.dateTime.month(.wide).locale(Self.english))
    }

    var dayAndMonth: String {
        formatted(.dateTime.day().month(.wide).locale(Self.english))
    }

    var shortDate: String {
        formatted(.dateTime.day().month(.abbreviated).locale(Self.english))
    }
}

extension Activity {
    static let samples: [Activity] = [
        Activity(title: "Flight to Crete", place: "Heraklion", date: day(28, 6), category: .travel, region: .crete, rating: 3,
                 note: "Up before sunrise, out of Frankfurt, transfer down to the south coast in the evening.",
                 duration: "4 hour flight"),
        Activity(title: "Check-in at Robinson Ierapetra", place: "Ierapetra", date: day(29, 6), category: .travel, region: .crete, rating: 4,
                 note: "Dropped the bags, walked the whole club, first jump into the sea.",
                 weather: "Sunny, 29 degrees"),
        Activity(title: "Archery at the club", place: "Ierapetra", date: day(30, 6), category: .sport, region: .crete, rating: 4,
                 note: "Two rounds on the range behind the sports field.",
                 duration: "1 hour"),
        Activity(title: "Stand-up paddling at sunrise", place: "Ierapetra", date: day(1, 7), category: .watersports, region: .crete, rating: 4,
                 note: "Out before breakfast, the water was still completely flat.",
                 duration: "45 minutes"),
        Activity(title: "Beach volleyball tournament", place: "Ierapetra", date: day(2, 7), category: .sport, region: .crete, rating: 4,
                 note: "Made it to the semi-final with the team, could barely walk afterwards.",
                 duration: "3 hours"),
        Activity(title: "Boat trip to Chrissi", place: "Chrissi Island", date: day(3, 7), category: .dayTrip, region: .crete, rating: 5,
                 note: "Uninhabited island off Ierapetra, water as turquoise as on the postcards.",
                 duration: "Full day", weather: "Sunny, 33 degrees"),
        Activity(title: "Jet ski at Vai Beach", place: "Vai", date: day(4, 7), category: .watersports, region: .crete, rating: 5,
                 note: "Half an hour out on open water in front of the palm beach. Careful at first, full throttle over the waves after five minutes. Salt in my eyes, arms completely done by the end.",
                 duration: "30 minutes", weather: "Sunny, 31 degrees"),
        Activity(title: "Palm forest of Vai", place: "Vai", date: day(4, 7), category: .nature, region: .crete, rating: 5,
                 note: "The largest palm grove in Europe, right behind the beach.",
                 duration: "2 hours"),
        Activity(title: "Spinalonga and Elounda", place: "Elounda", date: day(5, 7), category: .dayTrip, region: .crete, rating: 4,
                 note: "Walked the old fortress island, then ice cream in Elounda.",
                 duration: "Half day"),
        Activity(title: "Gyros in the old town", place: "Ierapetra", date: day(6, 7), category: .food, region: .crete, rating: 5,
                 note: "Small taverna in a side street, last evening down at the harbour."),
        Activity(title: "Flight home", place: "Heraklion", date: day(7, 7), category: .travel, region: .crete, rating: 2,
                 note: "Suitcase full of sand, sunburn across both shoulders.",
                 duration: "4 hour flight"),
        Activity(title: "Outdoor pool with the boys", place: "[YOUR PLACE]", date: day(14, 7), category: .watersports, region: .home, rating: 4,
                 note: "Diving tower, chips, half the afternoon in the water."),
        Activity(title: "Open-air cinema", place: "[YOUR PLACE]", date: day(22, 7), category: .dayTrip, region: .home, rating: 4,
                 note: "Brought a blanket and still got cold."),
        Activity(title: "Bike ride around the lake", place: "[YOUR PLACE]", date: day(3, 8), category: .nature, region: .home, rating: 4,
                 note: "All the way round, break on the jetty."),
        Activity(title: "Barbecue in the garden", place: "Home", date: day(11, 8), category: .food, region: .home, rating: 5,
                 note: "Half the class turned up, sat outside past midnight."),
        Activity(title: "Skatepark session", place: "[YOUR PLACE]", date: day(24, 8), category: .sport, region: .home, rating: 3,
                 note: "Almost landed a new trick, took the knee instead.")
    ]

    private static func day(_ day: Int, _ month: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: month, day: day)) ?? .now
    }
}
