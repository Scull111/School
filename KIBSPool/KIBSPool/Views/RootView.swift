import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var consent: ConsentStore
    @EnvironmentObject var store: RideStore

    var body: some View {
        Group {
            if let user = auth.current {
                if consent.hasConsent(user) {
                    MainTabView()
                        .onAppear { store.load(for: user) }
                } else {
                    ConsentView(user: user)
                }
            } else {
                LoginView()
            }
        }
        .animation(.default, value: auth.current)
    }
}

struct LoginView: View {
    @EnvironmentObject var auth: AuthService
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "leaf.circle.fill").font(.system(size: 72)).foregroundStyle(Theme.green)
            Text("KIBS Pool").font(.largeTitle.bold())
            Text("Melde dich mit den Zugangsdaten an, die du von der Schule bekommen hast.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            VStack(spacing: 12) {
                TextField("Benutzername", text: $username)
                    .textContentType(.username).textInputAutocapitalization(.never).autocorrectionDisabled()
                SecureField("Passwort", text: $password).textContentType(.password)
            }
            .textFieldStyle(.roundedBorder)
            if let e = auth.loginError {
                Text(e).font(.footnote).foregroundStyle(.red)
            }
            Button("Anmelden") { auth.login(username: username, password: password) }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(username.isEmpty || password.isEmpty)
            Spacer()
            Text("Kein Tracking · Keine Werbung · Daten bleiben auf deinem Gerät")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(24)
    }
}

struct ConsentView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var consent: ConsentStore
    let user: User
    @State private var agreed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Datenschutz & Einwilligung").font(.title.bold())
                    Text("Hallo \(user.displayName). Bevor du KIBS Pool nutzt, solltest du wissen, was mit deinen Daten passiert:")
                    bullet("lock.shield", "Kein Tracking", "Wir erfassen keinen Standort im Hintergrund und nutzen keine Analyse- oder Werbe-SDKs.")
                    bullet("iphone", "Lokale Speicherung", "Fahrten, Nachrichten und Eco-Daten liegen nur verschlüsselt auf diesem Gerät.")
                    bullet("person.2", "Sichtbarkeit", "Mitfahrende sehen nur deinen Vornamen und den Anfangsbuchstaben des Nachnamens.")
                    bullet("figure.and.child.holdinghands", "Elternkontrolle", "Schüler:innen können nur mit verifizierten Fahrer:innen fahren, solange die Elternkontrolle aktiv ist.")
                    bullet("trash", "Deine Rechte", "Unter Mehr → Datenspeicher kannst du Daten exportieren, löschen und die Einwilligung widerrufen.")
                    Toggle("Ich habe die Hinweise gelesen und willige ein.", isOn: $agreed).padding(.top)
                    Button("Zustimmen & weiter") { consent.give(user) }
                        .buttonStyle(PrimaryButtonStyle()).disabled(!agreed)
                    Button("Ablehnen und abmelden", role: .destructive) { auth.logout() }
                        .frame(maxWidth: .infinity)
                }
                .padding(24)
            }
        }
    }

    private func bullet(_ icon: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).foregroundStyle(Theme.green).frame(width: 28)
            VStack(alignment: .leading) { Text(title).bold(); Text(text).font(.subheadline).foregroundStyle(.secondary) }
        }
    }
}

struct MainTabView: View {
    @State private var tab = 0
    var body: some View {
        TabView(selection: $tab) {
            HomeView(goToRides: { tab = 1 }).tabItem { Label("Start", systemImage: "house.fill") }.tag(0)
            RidesView().tabItem { Label("Fahrten", systemImage: "car.fill") }.tag(1)
            EcoView().tabItem { Label("Eco", systemImage: "leaf.fill") }.tag(2)
            MoreView().tabItem { Label("Mehr", systemImage: "line.3.horizontal") }.tag(3)
        }
    }
}
