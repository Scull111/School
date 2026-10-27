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
    @State private var mode: TransportMode = .bike
    @State private var km = 3.0
    @State private var date = Date()
    @State private var confirmation: String?

    private var saved: Double { mode.savedKg(km: km) }

    var body: some View {
        List {
            Section("Wie bist du unterwegs gewesen?") {
                ForEach(TransportMode.allCases) { m in
                    Button { mode = m } label: {
                        HStack {
                            Image(systemName: m.symbol).frame(width: 32).foregroundStyle(Theme.green)
                            Text(m.rawValue).foregroundStyle(.primary)
                            Spacer()
                            Text("\(Int(m.gramsPerKm)) g CO₂/km").font(.caption).foregroundStyle(.secondary)
                            Image(systemName: mode == m ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(mode == m ? Theme.green : .gray)
                        }
                    }
                }
            }
            Section("Strecke") {
                Stepper(value: $km, in: 0.5...50, step: 0.5) {
                    Text("\(km.formatted(.number.precision(.fractionLength(0...1)))) km")
                }
                DatePicker("Datum", selection: $date, in: ...Date.now, displayedComponents: .date)
                HStack {
                    Image(systemName: "leaf.fill").foregroundStyle(Theme.green)
                    Text("Spart \(saved.formatted(.number.precision(.fractionLength(2)))) kg CO₂").bold()
                }
                Button("Eintragen") {
                    store.logTrip(mode, km: km, on: date)
                    confirmation = "\(mode.rawValue), \(km.formatted(.number.precision(.fractionLength(0...1)))) km eingetragen."
                }.buttonStyle(PrimaryButtonStyle())
                if let c = confirmation { Text(c).font(.footnote).foregroundStyle(Theme.green) }
            }
            Section("Verlauf") {
                if store.tripLogs.isEmpty { Text("Noch keine Wege eingetragen.").foregroundStyle(.secondary) }
                ForEach(store.tripLogs.sorted { $0.date > $1.date }) { log in
                    HStack {
                        Image(systemName: log.mode.symbol).foregroundStyle(Theme.green)
                        VStack(alignment: .leading) {
                            Text(log.mode.rawValue)
                            Text("\(log.distanceKm.formatted(.number.precision(.fractionLength(0...1)))) km")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("−\(log.savedKg.formatted(.number.precision(.fractionLength(2)))) kg").foregroundStyle(Theme.green)
                            Text(log.date, format: .dateTime.day().month()).font(.caption).foregroundStyle(.secondary)
                        }
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
