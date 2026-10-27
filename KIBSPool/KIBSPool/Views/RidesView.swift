import SwiftUI

struct RidesView: View {
    @EnvironmentObject var store: RideStore
    @State private var query = ""
    @State private var tagFilter: RideTag?
    @State private var showOffer = false

    private var results: [Ride] {
        store.search(destinationContains: query)
            .filter { tagFilter == nil || $0.tags.contains(tagFilter!) }
    }

    var body: some View {
        NavigationStack {
            List {
                if let booked = store.bookedRide {
                    Section("Deine Fahrt") {
                        NavigationLink { ActiveRideView(ride: booked) } label: { RideRow(ride: booked) }
                    }
                }
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            tagButton(nil, "Alle")
                            ForEach(RideTag.allCases) { tagButton($0, $0.rawValue) }
                        }
                    }
                }
                Section(header: Text("Angebotene Fahrten ab \(RideStore.school)")) {
                    if results.isEmpty { Text("Keine Fahrten gefunden.").foregroundStyle(.secondary) }
                    ForEach(results) { ride in
                        NavigationLink { SelectRideView(ride: ride) } label: { RideRow(ride: ride) }
                    }
                }
            }
            .searchable(text: $query, prompt: "Wohin?")
            .navigationTitle("Fahrten")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showOffer = true } label: { Label("Fahrt anbieten", systemImage: "plus.circle.fill") }
                }
            }
            .sheet(isPresented: $showOffer) { OfferRideView() }
        }
    }

    private func tagButton(_ tag: RideTag?, _ title: String) -> some View {
        Button { tagFilter = tag } label: {
            Text(title).font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                .foregroundStyle(tagFilter == tag ? .white : Theme.green)
                .background(tagFilter == tag ? Theme.green : Theme.greenSoft, in: Capsule())
        }.buttonStyle(.plain)
    }
}

struct RideRow: View {
    let ride: Ride
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(ride.origin) → \(ride.destination)").font(.headline)
                Spacer()
                Text(ride.price, format: .currency(code: "EUR")).bold()
            }
            HStack(spacing: 8) {
                Label(DateFormatter.clock.string(from: ride.departure) + " Uhr", systemImage: "clock")
                Label("\(ride.freeSeats) frei", systemImage: "person.fill")
                Label(ride.distanceKm.formatted(.number.precision(.fractionLength(0...1))) + " km", systemImage: "road.lanes")
                if ride.driverVerified { Label(ride.driverName, systemImage: "checkmark.seal.fill").foregroundStyle(Theme.green) }
            }.font(.subheadline).foregroundStyle(.secondary)
            HStack { ForEach(ride.tags) { Chip(text: $0.rawValue) } }
        }.padding(.vertical, 4)
    }
}

struct SelectRideView: View {
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    let ride: Ride
    @State private var pool = true

    private var blockedByParentalControl: Bool {
        (auth.current?.parentalControl ?? false) && !ride.driverVerified
    }
    private var savedKg: Double { TransportMode.pool.savedKg(km: ride.distanceKm) }
    private var soloPrice: Double { (ride.price * 2.45 * 10).rounded() / 10 }
    private var soloArrival: Date { ride.arrival.addingTimeInterval(-7 * 60) }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(ride.destination).font(.headline)
                        Text("Heute, \(DateFormatter.clock.string(from: ride.departure)) Uhr").foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "leaf.fill").foregroundStyle(Theme.green)
                        .frame(width: 44, height: 44).background(Theme.greenSoft, in: Circle())
                }.card()

                option(selected: pool, title: "Pool", icon: "person.3.fill", tags: ["geteilt", "günstig", "grün"],
                       price: ride.price, arrival: ride.arrival, riders: ride.passengers.count) { pool = true }
                option(selected: !pool, title: "Solo", icon: "person.fill", tags: [],
                       price: soloPrice, arrival: soloArrival, riders: nil) { pool = false }

                HStack {
                    Image(systemName: "leaf").foregroundStyle(Theme.green)
                    Text("Spart \(savedKg.formatted(.number.precision(.fractionLength(1)))) kg CO₂ gegenüber Einzelfahrt").bold()
                    Spacer()
                }.card()

                if store.bookedRideID != nil {
                    Text("Du hast bereits eine Fahrt gebucht.").foregroundStyle(.secondary)
                } else if blockedByParentalControl {
                    Text("Die Elternkontrolle erlaubt nur verifizierte Fahrer:innen.").foregroundStyle(.red)
                }
                Button(pool ? "Pool wählen" : "Solo wählen") {
                    store.book(ride, as: auth.current?.displayName ?? "")
                    NotificationService.requestPermission()
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(store.bookedRideID != nil || ride.freeSeats == 0 || blockedByParentalControl)
            }.padding(16)
        }
        .navigationTitle("Fahrt auswählen")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func option(selected: Bool, title: String, icon: String, tags: [String],
                        price: Double, arrival: Date, riders: Int?, tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon).foregroundStyle(selected ? Theme.green : .gray)
                        .frame(width: 52, height: 52).background(selected ? Theme.greenSoft : Color(.systemGray5), in: Circle())
                    VStack(alignment: .leading) {
                        Text(title).font(.title2.bold())
                        HStack { ForEach(tags, id: \.self) { Chip(text: $0) } }
                    }
                    Spacer()
                    Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                        .font(.title).foregroundStyle(selected ? Theme.green : .gray)
                }
                Divider()
                HStack {
                    Label(price.formatted(.currency(code: "EUR")), systemImage: "eurosign.circle")
                    Spacer()
                    Label("Ankunft \(DateFormatter.clock.string(from: arrival)) Uhr", systemImage: "clock")
                    if let riders { Spacer(); Label("\(riders) Mitfahrer", systemImage: "person") }
                }.font(.subheadline).foregroundStyle(.primary)
            }
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? Theme.green : .clear, lineWidth: 2))
        }.buttonStyle(.plain)
    }
}

struct OfferRideView: View {
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var place = ""
    @State private var departure = Date()
    @State private var distanceKm = 5.0
    @State private var seats = 3
    @State private var price = 2.50
    @State private var vehicle = ""
    @State private var tags: Set<RideTag> = [.geteilt]

    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Start", value: RideStore.school)
                TextField("Zielort", text: $place)
                Stepper("Strecke: \(distanceKm.formatted(.number.precision(.fractionLength(0...1)))) km",
                        value: $distanceKm, in: 1...50, step: 0.5)
                TextField("Fahrzeug (z. B. VW ID.4)", text: $vehicle)
                DatePicker("Abfahrt", selection: $departure)
                Stepper("Freie Plätze: \(seats)", value: $seats, in: 1...6)
                Stepper("Preis: \(price.formatted(.currency(code: "EUR")))", value: $price, in: 0...10, step: 0.5)
                Section("Tags") {
                    ForEach(RideTag.allCases) { tag in
                        Toggle(tag.rawValue, isOn: Binding(get: { tags.contains(tag) },
                                                           set: { $0 ? tags.insert(tag) : tags.remove(tag) }))
                    }
                }
            }
            .navigationTitle("Fahrt anbieten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Anbieten") {
                        let u = auth.current
                        store.offer(Ride(id: UUID(), driverName: u?.displayName ?? "", driverVerified: u?.verified ?? false,
                                         vehicle: vehicle, plate: "", origin: RideStore.school,
                                         destination: place, departure: departure,
                                         arrival: departure.addingTimeInterval(distanceKm * 3.5 * 60),
                                         distanceKm: distanceKm, seats: seats, passengers: [],
                                         price: price, tags: Array(tags), isOwn: true))
                        dismiss()
                    }.disabled(place.isEmpty)
                }
            }
        }
    }
}
