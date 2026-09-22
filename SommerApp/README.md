# Sommer 26

Eine kleine SwiftUI-App, die meinen Sommer zeigt: die Reise nach Kreta (Robinson Ierapetra,
Jetski am Vai Beach, Chrissi Island) und alles, was zuhause noch dazukam.

## Aufbau

| Datei | Inhalt |
| --- | --- |
| `SommerApp.swift` | App-Einstieg und Tab-Navigation (Sommer, Timeline, Neu, Ich) |
| `Theme.swift` | Farben, Schrift, wiederverwendbare Bausteine |
| `Model.swift` | `Activity`, `Trip`, `Category`, `SummerStore` |
| `SummerData.swift` | Die Einträge des Sommers |
| `SummerView.swift` | Startseite mit Reisekarte, Zahlen und letzten Einträgen |
| `TimelineView.swift` | Alle Einträge nach Monat, filterbar nach Kreta / Zuhause |
| `TripView.swift` | Die Reise mit Highlights und Fotoplätzen |
| `ActivityDetailView.swift` | Ein einzelner Eintrag |
| `NewEntryView.swift` | Neuen Eintrag anlegen |
| `ProfileView.swift` | Sommer in Zahlen |

## Starten

Neues Xcode-Projekt (iOS App, SwiftUI, iOS 17 oder neuer) anlegen, die vorgegebene
`ContentView.swift` und die generierte App-Datei löschen und die Dateien aus diesem Ordner
hinzufügen. Die App läuft ohne weitere Abhängigkeiten.

## Platzhalter

Stellen, an denen echte Angaben fehlen, stehen als `[DEIN ORT]`, `[MIT WEM]`, `[DEIN NAME]`
in `SummerData.swift` und lassen sich dort direkt ersetzen. Fotos sind als Platzhalterflächen
angelegt.
