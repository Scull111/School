# Summer 26

A small SwiftUI app that shows my summer: the trip to Crete (Robinson Ierapetra, jet ski at
Vai Beach, Chrissi Island) and everything that happened back home.

## Running it

Double-click `SummerApp.xcodeproj`, pick a simulator at the top (e.g. iPhone 16) and hit Play.
No dependencies, nothing to set up.

To run it on a real iPhone, choose your own Apple team under *Signing & Capabilities* and
change the bundle ID `com.example.summer26` to something of your own.

Needs iOS 17 and Xcode 15 or newer.

## Structure

| File | Contents |
| --- | --- |
| `SummerApp.swift` | App entry point and tab navigation (Summer, Timeline, New, Me) |
| `Model.swift` | `Activity`, `Trip`, `Category`, `SummerStore` |
| `SummerData.swift` | The entries of the summer |
| `Theme.swift` | Colours, type and reusable pieces |
| `ActivityRow.swift` | One row in the lists |
| `SummerView.swift` | Home screen with the trip card, numbers and recent entries |
| `TimelineView.swift` | Every entry by month, filterable by Crete / Home |
| `TripView.swift` | The trip with highlights and photo slots |
| `ActivityDetailView.swift` | A single entry |
| `NewEntryView.swift` | Add a new entry |
| `ProfileView.swift` | Summer in numbers |

## Placeholders

Anywhere a real detail is missing there is a `[YOUR PLACE]`, `[WITH WHOM]` or `[YOUR NAME]`
in `SummerData.swift`, ready to be replaced. Photos are drawn as placeholder blocks.
