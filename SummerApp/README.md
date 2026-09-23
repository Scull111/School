# Summer 26

A small SwiftUI app that shows my summer: the trip to Crete (Robinson Ierapetra, jet ski at
Vai Beach, Chrissi Island) and everything that happened back home.

## Running it

Double-click `SummerApp.xcodeproj`, pick a simulator at the top (e.g. iPhone 16) and hit Play.
No dependencies, nothing to set up.

To run it on a real iPhone, choose your own Apple team under *Signing & Capabilities* and
change the bundle ID `com.example.summer26` to something of your own.

Needs iOS 17 and Xcode 15 or newer.

## What it does

- **Browse** the summer from the home screen, the timeline, or the trip page.
- **Add** an entry from the New tab.
- **Edit** any entry: open it and tap *Edit*, or swipe a timeline row to the right.
- **Delete** an entry: swipe a timeline row to the left, or use *Delete entry* at the
  bottom of the entry. Both ask before deleting.
- **Photos** come from your library through the system picker. Pick up to six at a time per
  entry, remove one with the ✗ on its thumbnail. An entry with photos shows them as a swipeable
  gallery, uses the first one as its row thumbnail, and fills the photo row on the trip page.

## One source of truth

Every screen reads the same `SummerStore`, handed down once from `SummerApp` through
`.environment`. No view keeps its own copy of an entry: `ActivityDetailView` looks its entry up
by id on every draw, `TripView` reads `store.trip`, and the lists are computed from
`store.activities`. Change a title in the editor and the timeline row, the home screen, the
trip highlights and the stats all show it immediately.

The store writes itself to `Documents/summer.json` after every add, edit and delete, and loads
from there on launch, falling back to the sample summer the first time. Photos live in
`Documents/Photos` as downscaled JPEGs; an entry stores only their file names, and files no
longer referenced are cleaned up on the next save.

## Structure

| File | Contents |
| --- | --- |
| `SummerApp.swift` | App entry point and tab navigation (Summer, Timeline, New, Me) |
| `Model.swift` | `Activity`, `Trip`, `Category`, `SummerStore` |
| `SummerData.swift` | The entries of the summer |
| `Theme.swift` | Colours, type and reusable pieces |
| `PhotoStore.swift` | Photos on disk, downscaled and cached |
| `ActivityRow.swift` | One row in the lists |
| `SummerView.swift` | Home screen with the trip card, numbers and recent entries |
| `TimelineView.swift` | Every entry by month, filterable, swipe to edit or delete |
| `TripView.swift` | The trip with highlights and photos |
| `ActivityDetailView.swift` | A single entry, with edit and delete |
| `ActivityEditor.swift` | The form for adding and editing, including the photo picker |
| `ProfileView.swift` | Summer in numbers |

## Placeholders

Anywhere a real detail is missing there is a `[YOUR PLACE]`, `[WITH WHOM]` or `[YOUR NAME]`
in `SummerData.swift`, ready to be replaced.
