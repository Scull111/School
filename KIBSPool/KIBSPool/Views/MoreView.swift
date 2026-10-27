import SwiftUI

struct MoreView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var store: RideStore

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { AccountView() } label: { Label("Konto", systemImage: "person.crop.circle") }
                    NavigationLink { TransportLogView() } label: { Label("Verkehrsmittel eintragen", systemImage: "figure.walk.motion") }
                    NavigationLink { NotificationsView() } label: {
                        Label("Benachrichtigungen", systemImage: "bell")
                            .badge(store.notifications.count)
                    }
                }
                Section {
                    Button("Abmelden", role: .destructive) { auth.logout() }
                }
            }
            .navigationTitle("Mehr")
        }
    }
}

struct AccountView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var consent: ConsentStore
    @Environment(\.dismiss) private var dismiss
    @State private var showExport = false
    @State private var confirmErase = false

    var body: some View {
        NavigationStack {
            Form {
                if let u = auth.current {
                    Section("Profil") {
                        LabeledContent("Name", value: u.displayName)
                        LabeledContent("Benutzername", value: u.username)
                        if let c = u.className { LabeledContent("Klasse", value: c) }
                        LabeledContent("Status", value: u.verified ? "Verifiziert" : "Ausstehend")
                    }
                    Section("Elternkontrolle") {
                        Toggle("Nur verifizierte Fahrer:innen", isOn: Binding(
                            get: { u.parentalControl }, set: { auth.setParentalControl($0) }))
                        Text("Ist die Elternkontrolle aktiv, können nur Fahrten mit von der Schule verifizierten Fahrer:innen gebucht werden.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Section("Datenspeicher") {
                        Text("Alle Daten liegen ausschließlich lokal auf diesem Gerät. Es gibt kein Tracking und keine Weitergabe.")
                            .font(.footnote).foregroundStyle(.secondary)
                        Button("Meine Daten exportieren") { showExport = true }
                        Button("Fahrtdaten löschen", role: .destructive) { confirmErase = true }
                        Button("Einwilligung widerrufen & abmelden", role: .destructive) {
                            consent.revoke(u); auth.logout()
                        }
                    }
                }
            }
            .navigationTitle("Konto")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Fertig") { dismiss() } } }
            .sheet(isPresented: $showExport) {
                NavigationStack {
                    ScrollView { Text(store.exportJSON()).font(.system(.footnote, design: .monospaced)).padding() }
                        .navigationTitle("Datenexport")
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Fertig") { showExport = false } } }
                }
            }
            .confirmationDialog("Alle Fahrten, Nachrichten und Eco-Daten löschen?", isPresented: $confirmErase,
                                titleVisibility: .visible) {
                Button("Löschen", role: .destructive) { store.eraseAll() }
            }
        }
    }
}

struct TransportLogView: View {
    @EnvironmentObject var store: RideStore
    @State private var justLogged: TransportMode?

    var body: some View {
        List {
            Section("Wie bist du heute gekommen?") {
                ForEach(TransportMode.allCases) { mode in
                    Button {
                        store.logTrip(mode); justLogged = mode
                    } label: {
                        HStack {
                            Image(systemName: mode.symbol).frame(width: 32).foregroundStyle(Theme.green)
                            Text(mode.rawValue).foregroundStyle(.primary)
                            Spacer()
                            Text("\(mode.gramsCO2) g CO₂").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            if let m = justLogged {
                Text("\(m.rawValue) eingetragen.").foregroundStyle(Theme.green)
            }
            Section("Verlauf") {
                ForEach(store.tripLogs.reversed()) { log in
                    HStack {
                        Image(systemName: log.mode.symbol).foregroundStyle(Theme.green)
                        Text(log.mode.rawValue); Spacer()
                        Text(log.date, format: .dateTime.day().month().hour().minute()).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Verkehrsmittel")
    }
}

struct NotificationsView: View {
    @EnvironmentObject var store: RideStore
    var body: some View {
        List {
            if store.notifications.isEmpty { Text("Keine Benachrichtigungen.").foregroundStyle(.secondary) }
            ForEach(store.notifications) { n in
                VStack(alignment: .leading, spacing: 2) {
                    Text(n.title).font(.headline)
                    Text(n.body).font(.subheadline)
                    Text(n.date, format: .relative(presentation: .named)).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Benachrichtigungen")
    }
}
