import SwiftUI

@main
struct KIBSPoolApp: App {
    @StateObject private var auth = AuthService()
    @StateObject private var consent = ConsentStore()
    @StateObject private var store = RideStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(consent)
                .environmentObject(store)
                .tint(Theme.green)
        }
    }
}
