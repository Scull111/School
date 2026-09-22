import SwiftUI

@main
struct SommerApp: App {
    @State private var store = SummerStore.sample

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}

struct RootView: View {
    @State private var selection = Tab.sommer

    var body: some View {
        TabView(selection: $selection) {
            SummerView()
                .tag(Tab.sommer)
                .tabItem { Label("Sommer", systemImage: "sun.max") }

            TimelineView()
                .tag(Tab.timeline)
                .tabItem { Label("Timeline", systemImage: "list.bullet") }

            NewEntryView { selection = .timeline }
                .tag(Tab.neu)
                .tabItem { Label("Neu", systemImage: "plus.circle") }

            ProfileView()
                .tag(Tab.ich)
                .tabItem { Label("Ich", systemImage: "person") }
        }
        .tint(Theme.clay)
    }
}

enum Tab {
    case sommer, timeline, neu, ich
}
