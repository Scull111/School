import Foundation
import CryptoKit

/// Accounts are assigned by the school (no self-registration, no tracking).
/// Passwords are stored salted + hashed. Seed credentials are demo data only.
@MainActor
final class AuthService: ObservableObject {
    struct Account: Codable {
        var user: User
        var salt: String
        var hash: String
    }

    @Published private(set) var current: User?
    @Published var loginError: String?

    private var accounts: [Account] = []
    private let sessionKey = "session.userID"
    private let url = Persistence.url("accounts.json")

    init() {
        accounts = Persistence.load([Account].self, from: url) ?? []
        if accounts.isEmpty { seed() }
        if let raw = UserDefaults.standard.string(forKey: sessionKey),
           let id = UUID(uuidString: raw) {
            current = accounts.first { $0.user.id == id }?.user
        }
    }

    func login(username: String, password: String) {
        let name = username.trimmingCharacters(in: .whitespaces).lowercased()
        guard let acc = accounts.first(where: { $0.user.username == name }),
              Self.hash(password, salt: acc.salt) == acc.hash else {
            loginError = "Benutzername oder Passwort falsch."
            return
        }
        guard acc.user.verified else {
            loginError = "Dein Konto wurde noch nicht von der Schule freigegeben."
            return
        }
        loginError = nil
        current = acc.user
        UserDefaults.standard.set(acc.user.id.uuidString, forKey: sessionKey)
    }

    func logout() {
        current = nil
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    func setParentalControl(_ on: Bool) {
        guard let id = current?.id, let i = accounts.firstIndex(where: { $0.user.id == id }) else { return }
        accounts[i].user.parentalControl = on
        current = accounts[i].user
        Persistence.save(accounts, to: url)
    }

    private static func hash(_ password: String, salt: String) -> String {
        SHA256.hash(data: Data((salt + password).utf8)).map { String(format: "%02x", $0) }.joined()
    }

    private func seed() {
        let demo: [(String, String, String, Role, String?, Bool)] = [
            ("anna", "Anna K.", "kibs-anna-1", .student, "8b", true),
            ("ben", "Ben S.", "kibs-ben-2", .student, "7a", true),
            ("alex", "Alex M.", "kibs-alex-3", .driver, nil, true),
            ("eltern", "Familie K.", "kibs-eltern-4", .parent, nil, true),
            ("neu", "Neu Angemeldet", "kibs-neu-5", .student, "9c", false)
        ]
        accounts = demo.map { name, display, pw, role, cls, verified in
            let salt = UUID().uuidString
            return Account(
                user: User(id: UUID(), username: name, displayName: display, role: role,
                           className: cls, verified: verified, parentalControl: role == .student),
                salt: salt, hash: Self.hash(pw, salt: salt))
        }
        Persistence.save(accounts, to: url)
    }
}
