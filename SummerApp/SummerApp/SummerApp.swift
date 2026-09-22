import SwiftUI

@main
struct SummerApp: App {
    @State private var store = SummerStore.sample

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}

struct RootView: View {
    @State private var selection = Tab.summer

    var body: some View {
        TabView(selection: $selection) {
            SummerView()
                .tag(Tab.summer)
                .tabItem { Label("Summer", systemImage: "sun.max") }

            TimelineView()
                .tag(Tab.timeline)
                .tabItem { Label("Timeline", systemImage: "list.bullet") }

            ActivityEditor { selection = .summer }
                .tag(Tab.new)
                .tabItem { Label("New", systemImage: "plus.circle") }

            ProfileView()
                .tag(Tab.me)
                .tabItem { Label("Me", systemImage: "person") }
        }
        .tint(Theme.clay)
    }
}

enum Tab {
    case summer, timeline, new, me
}
