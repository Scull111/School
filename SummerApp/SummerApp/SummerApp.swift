import SwiftUI

@main
struct SummerApp: App {
    @State private var store = ActivityStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            SummerView()
                .tabItem { Label("Summer", systemImage: "sun.max") }

            TimelineView()
                .tabItem { Label("Timeline", systemImage: "list.bullet") }

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
        }
    }
}
