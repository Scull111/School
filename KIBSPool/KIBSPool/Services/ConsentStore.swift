import Foundation

/// Data-protection consent, asked once per account before the app is used.
@MainActor
final class ConsentStore: ObservableObject {
    static let version = 1
    @Published private var accepted: [String: Int]
    private let key = "consent.v1"

    init() {
        accepted = (UserDefaults.standard.dictionary(forKey: key) as? [String: Int]) ?? [:]
    }

    func hasConsent(_ user: User) -> Bool { accepted[user.username] == Self.version }

    func give(_ user: User) {
        accepted[user.username] = Self.version
        UserDefaults.standard.set(accepted, forKey: key)
    }

    func revoke(_ user: User) {
        accepted[user.username] = nil
        UserDefaults.standard.set(accepted, forKey: key)
    }
}
