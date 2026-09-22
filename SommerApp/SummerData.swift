import Foundation

extension SummerStore {
    static var sample: SummerStore {
        SummerStore(trip: kreta, activities: summer)
    }

    static let kreta = Trip(
        name: "Robinson Ierapetra",
        destination: "Kreta, Griechenland",
        start: day(28, 6),
        end: day(7, 7),
        note: """
        Neun Tage Club, Meer und viel zu viel Sonne. Der Tag am Vai Beach war der beste — \
        erst Jetski, danach barfuß durch den Palmenwald.
        """
    )

    static let summer: [Activity] = [
        Activity(
            title: "Anreise nach Kreta",
            place: "Heraklion",
            date: day(28, 6),
            category: .reise,
            region: .kreta,
            rating: 3,
            note: "Früh raus, Flug ab Frankfurt, abends mit dem Transfer an die Südküste.",
            duration: "4 Stunden Flug"
        ),
        Activity(
            title: "Check-in Robinson Ierapetra",
            place: "Ierapetra",
            date: day(29, 6),
            category: .zuhause,
            region: .kreta,
            rating: 4,
            note: "Zimmer bezogen, Club abgelaufen, erster Sprung ins Meer.",
            weather: "Sonne, 29 Grad"
        ),
        Activity(
            title: "Bogenschießen im Club",
            place: "Ierapetra",
            date: day(30, 6),
            category: .sport,
            region: .kreta,
            rating: 4,
            note: "Zwei Runden auf der Anlage hinter dem Sportplatz.",
            duration: "1 Stunde"
        ),
        Activity(
            title: "Stand-up Paddling am Morgen",
            place: "Ierapetra",
            date: day(1, 7),
            category: .wassersport,
            region: .kreta,
            rating: 4,
            note: "Vor dem Frühstück raus, das Wasser war noch komplett glatt.",
            duration: "45 Minuten"
        ),
        Activity(
            title: "Beachvolleyball-Turnier",
            place: "Ierapetra",
            date: day(2, 7),
            category: .sport,
            region: .kreta,
            rating: 4,
            note: "Im Team bis ins Halbfinale, danach nicht mehr laufen können.",
            duration: "3 Stunden"
        ),
        Activity(
            title: "Bootstour nach Chrissi",
            place: "Chrissi Island",
            date: day(3, 7),
            category: .ausflug,
            region: .kreta,
            rating: 5,
            note: "Unbewohnte Insel vor Ierapetra, Wasser so türkis wie auf Postkarten.",
            duration: "Ganzer Tag",
            weather: "Sonne, 33 Grad"
        ),
        Activity(
            title: "Jetski am Vai Beach",
            place: "Vai",
            date: day(4, 7),
            category: .wassersport,
            region: .kreta,
            rating: 5,
            note: """
            Halbe Stunde übers offene Wasser vor dem Palmenstrand. Am Anfang vorsichtig, \
            nach fünf Minuten Vollgas über die Wellen. Salz in den Augen, Arme am Ende \
            komplett platt — würde ich sofort nochmal machen.
            """,
            duration: "30 Minuten",
            weather: "Sonne, 31 Grad"
        ),
        Activity(
            title: "Palmenwald von Vai",
            place: "Vai",
            date: day(4, 7),
            category: .natur,
            region: .kreta,
            rating: 5,
            note: "Der größte Palmenhain Europas, direkt hinter dem Strand.",
            duration: "2 Stunden"
        ),
        Activity(
            title: "Spinalonga und Elounda",
            place: "Elounda",
            date: day(5, 7),
            category: .ausflug,
            region: .kreta,
            rating: 4,
            note: "Festungsinsel angeschaut, danach Eis in Elounda.",
            duration: "Halber Tag"
        ),
        Activity(
            title: "Gyros in der Altstadt",
            place: "Ierapetra",
            date: day(6, 7),
            category: .essen,
            region: .kreta,
            rating: 5,
            note: "Kleine Taverne in einer Seitengasse, letzter Abend am Hafen.",
            duration: "Abend"
        ),
        Activity(
            title: "Rückflug",
            place: "Heraklion",
            date: day(7, 7),
            category: .reise,
            region: .kreta,
            rating: 2,
            note: "Koffer voll Sand, Sonnenbrand auf den Schultern.",
            duration: "4 Stunden Flug"
        ),
        Activity(
            title: "Freibad mit den Jungs",
            place: "[DEIN ORT]",
            date: day(14, 7),
            category: .wassersport,
            region: .zuhause,
            rating: 4,
            note: "Sprungturm, Pommes, den halben Nachmittag im Becken."
        ),
        Activity(
            title: "Open-Air-Kino",
            place: "[DEIN ORT]",
            date: day(22, 7),
            category: .ausflug,
            region: .zuhause,
            rating: 4,
            note: "Decke mitgenommen, es wurde trotzdem kalt."
        ),
        Activity(
            title: "Fahrradtour um den See",
            place: "[DEIN ORT]",
            date: day(3, 8),
            category: .natur,
            region: .zuhause,
            rating: 4,
            note: "Einmal komplett rum, Pause am Steg."
        ),
        Activity(
            title: "Grillabend im Garten",
            place: "Zuhause",
            date: day(11, 8),
            category: .essen,
            region: .zuhause,
            rating: 5,
            note: "Halbe Klasse da, bis nach Mitternacht draußen gesessen."
        ),
        Activity(
            title: "Skatepark-Session",
            place: "[DEIN ORT]",
            date: day(24, 8),
            category: .sport,
            region: .zuhause,
            rating: 3,
            note: "Neuer Trick fast gestanden, Knie dafür aufgeschlagen."
        )
    ]

    static func day(_ day: Int, _ month: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: month, day: day)) ?? .now
    }
}
