# Sommer 26

Eine kleine SwiftUI-App, die meinen Sommer zeigt: die Reise nach Kreta (Robinson Ierapetra,
Jetski am Vai Beach, Chrissi Island) und alles, was zuhause noch dazukam.

## Starten

`SommerApp.xcodeproj` doppelklicken, oben einen Simulator wählen (z. B. iPhone 16) und auf
Play drücken. Keine Abhängigkeiten, nichts einzurichten.

Für einen echten Test auf dem iPhone unter *Signing & Capabilities* das eigene Apple-Team
auswählen und die Bundle-ID `com.example.sommer26` auf etwas Eigenes ändern.

Mindestens iOS 17 und Xcode 15.

## Aufbau

| Datei | Inhalt |
| --- | --- |
| `SommerApp.swift` | App-Einstieg und Tab-Navigation (Sommer, Timeline, Neu, Ich) |
| `Model.swift` | `Activity`, `Trip`, `Category`, `SummerStore` |
| `SummerData.swift` | Die Einträge des Sommers |
| `Theme.swift` | Farben, Schrift, wiederverwendbare Bausteine |
| `ActivityRow.swift` | Eine Zeile in den Listen |
| `SummerView.swift` | Startseite mit Reisekarte, Zahlen und letzten Einträgen |
| `TimelineView.swift` | Alle Einträge nach Monat, filterbar nach Kreta / Zuhause |
| `TripView.swift` | Die Reise mit Highlights und Fotoplätzen |
| `ActivityDetailView.swift` | Ein einzelner Eintrag |
| `NewEntryView.swift` | Neuen Eintrag anlegen |
| `ProfileView.swift` | Sommer in Zahlen |

## Platzhalter

Stellen, an denen echte Angaben fehlen, stehen als `[DEIN ORT]`, `[MIT WEM]`, `[DEIN NAME]`
in `SummerData.swift` und lassen sich dort direkt ersetzen. Fotos sind als Platzhalterflächen
angelegt.
