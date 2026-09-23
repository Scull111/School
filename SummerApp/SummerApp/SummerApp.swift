import SwiftUI

@main
struct SummerApp: App {
    @State private var store = ActivityStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
