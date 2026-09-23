# Summer 26

A small SwiftUI app that lists what I did over the summer — the trip to Crete (Robinson
Ierapetra, jet ski at Vai Beach, Chrissi Island) and everything back home.

## Running it

Open `SummerApp.xcodeproj`, pick a simulator and hit Play. No dependencies.

For a real iPhone, set your own team under *Signing & Capabilities* and change the bundle ID
`com.example.summer26`.

Needs iOS 17 and Xcode 15 or newer.

## What it does

- One list of entries, grouped by month, filtered by Crete / Home.
- Tap an entry for the details, **Edit** to change it, **Delete Entry** to remove it.
- Swipe a row to delete it from the list.
- **+** adds a new entry.
- Photos come from the library through `PhotosPicker`, up to five per entry.

Everything reads from one `ActivityStore`, so a change in the form shows up in the list and the
counts right away. The store saves itself to `Documents/activities.json` after every change and
loads it at launch; the sample summer only seeds the first run.

## Files

| File | Contents |
| --- | --- |
| `SummerApp.swift` | App entry point |
| `Activity.swift` | The model, its enums and the sample summer |
| `ActivityStore.swift` | The list of entries, loaded from and saved to JSON |
| `ContentView.swift` | The main list |
| `ActivityDetailView.swift` | One entry |
| `ActivityFormView.swift` | Add and edit |

## Known simplifications

- Photos are stored as raw `Data` inside the JSON file, so the file grows quickly with a lot of
  pictures. Writing images to their own files would be the fix.
- Placeholders like `[YOUR PLACE]` sit in `Activity.swift` where a real detail is missing.
