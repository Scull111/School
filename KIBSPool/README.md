# KIBS Pool (SwiftUI, iOS 17+)

Umsetzung der vier Screens aus „KIBS Pool Mobile-App-UI“ (Start, Fahrt auswählen, Fahrt läuft, Eco-Dashboard) plus Konto-/Mehr-Bereich.

## Starten (Mac mit Xcode 15+)
```
brew install xcodegen
cd KIBSPool && xcodegen && open KIBSPool.xcodeproj
```
Oder in Xcode ein neues iOS-App-Projekt anlegen und den Ordner `KIBSPool/` hineinziehen.

## Demo-Zugänge (von der Schule vergeben – keine Selbstregistrierung)
| Benutzer | Passwort | Hinweis |
|---|---|---|
| anna | kibs-anna-1 | Schülerin 8b, Elternkontrolle an |
| ben | kibs-ben-2 | Schüler 7a |
| alex | kibs-alex-3 | Fahrer |
| eltern | kibs-eltern-4 | Elternkonto |
| neu | kibs-neu-5 | noch nicht verifiziert → Login wird abgelehnt |

Passwörter werden gesalzen (SHA-256) gespeichert. Für den Produktivbetrieb: Konten serverseitig bereitstellen und PBKDF2/Argon2 + Keychain verwenden.

## Umgesetzt
- Kein Tracking: keine Analyse-SDKs, kein Standortzugriff, nur lokale Speicherung (`completeFileProtection`)
- (Vor-)Verifizierung: vergebene Benutzernamen/Passwörter, Konto muss freigegeben sein; Fahrer-Verifizierung sichtbar
- Datenschutz-Einwilligung beim ersten Start (widerrufbar)
- Angebotene Fahrten (Start oder Ziel ist immer die Schule), Suche, Tag-Filter, Fahrt anbieten mit Zielort und Strecke
- Verkehrsmittel eintragen (Zu Fuß, Fahrrad, E-Scooter, Bus, Bahn, Mitfahren, Elterntaxi) mit Strecke in km; der CO₂-Score ergibt sich aus der Ersparnis gegenüber derselben Strecke allein im Auto (170 g/km). Abgeschlossene Pool-Fahrten fließen automatisch ein
- Lokale Fahrt-Benachrichtigungen
- Konto: Elternkontrolle, Datenspeicher (Export/Löschen)
- Nice-to-have: Tags, Chat (lokal), CO₂-Bilanz, Klassenranking

## Offen
- Cloudflare / Backend (Chat, Fahrten und Ranking sind aktuell nur lokal bzw. Beispieldaten)
- Konto-Bereich war im Entwurf „später“ markiert und ist hier eine einfache Version
