import SwiftUI
import MapKit

struct ActiveRideView: View {
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    let ride: Ride
    @State private var showChat = false
    @State private var showSafety = false

    private var minutesLeft: Int { max(0, Int(ride.arrival.timeIntervalSinceNow / 60)) }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill").font(.system(size: 64)).foregroundStyle(.gray.opacity(0.5))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ride.driverName).font(.title2.bold())
                        if ride.driverVerified {
                            Label("Verifizierter Fahrer", systemImage: "checkmark.circle.fill").foregroundStyle(Theme.green)
                        }
                        Text("\(ride.vehicle) · \(ride.plate)").foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button { showChat = true } label: {
                        VStack { Image(systemName: "message.fill").font(.title3)
                            .frame(width: 48, height: 48).background(Theme.greenSoft, in: Circle())
                            Text("Chat").font(.caption) }
                    }
                }.card()

                RouteCard(ride: ride)

                HStack {
                    Image(systemName: "clock").font(.title2).foregroundStyle(Theme.green)
                        .frame(width: 52, height: 52).background(Theme.greenSoft, in: Circle())
                    Text("Ankunft in").font(.title2.bold())
                    Text("\(minutesLeft) Min.").font(.title2.bold()).foregroundStyle(Theme.green)
                    Spacer()
                }.card()

                HStack {
                    ForEach(0..<min(3, ride.passengers.count), id: \.self) { _ in
                        Image(systemName: "person.crop.circle.fill").font(.largeTitle).foregroundStyle(.gray.opacity(0.5))
                    }
                    Text("\(ride.passengers.count) Mitfahrer").font(.headline)
                    Spacer()
                }.card()

                Label("Fahrt sicher unterwegs", systemImage: "checkmark.shield.fill")
                    .foregroundStyle(Theme.green).frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14).background(Theme.greenSoft, in: RoundedRectangle(cornerRadius: 16))

                Button("Fahrt abschließen") {
                    store.logTrip(.pool, km: ride.distanceKm); store.cancelBookingAfterRide(); dismiss()
                }.buttonStyle(PrimaryButtonStyle())
                Button("Buchung stornieren", role: .destructive) {
                    store.cancelBooking(as: auth.current?.displayName ?? ""); dismiss()
                }
            }.padding(16)
        }
        .navigationTitle("Fahrt läuft")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSafety = true } label: { Image(systemName: "cross.case.fill") }
            }
        }
        .sheet(isPresented: $showChat) { ChatView(ride: ride) }
        .alert("Sicherheit", isPresented: $showSafety) {
            Button("Notruf 112") { if let u = URL(string: "tel://112") { UIApplication.shared.open(u) } }
            Button("Schließen", role: .cancel) {}
        } message: { Text("Bei Gefahr wähle den Notruf. Die Schule kann über das Sekretariat informiert werden.") }
    }
}

struct RouteCard: View {
    let ride: Ride
    var body: some View {
        let kibs = HomeView.kibs
        let home = CLLocationCoordinate2D(latitude: kibs.latitude - 0.02, longitude: kibs.longitude + 0.012)
        let stop1 = CLLocationCoordinate2D(latitude: kibs.latitude - 0.007, longitude: kibs.longitude + 0.004)
        let stop2 = CLLocationCoordinate2D(latitude: kibs.latitude - 0.014, longitude: kibs.longitude + 0.009)
        let path = [kibs, stop1, stop2, home]
        Map(interactionModes: []) {
            MapPolyline(coordinates: path).stroke(Theme.green, lineWidth: 5)
            Marker("KIBS Hannover", coordinate: kibs).tint(Theme.green)
            Marker("Stopp 1", coordinate: stop1).tint(.white)
            Marker("Stopp 2", coordinate: stop2).tint(.white)
            Marker("Zuhause", coordinate: home).tint(Theme.green)
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ChatView: View {
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    let ride: Ride
    @State private var text = ""

    var body: some View {
        NavigationStack {
            VStack {
                List(store.messages.filter { $0.rideID == ride.id }) { m in
                    VStack(alignment: .leading) {
                        Text(m.sender).font(.caption).foregroundStyle(.secondary)
                        Text(m.text)
                    }
                }
                HStack {
                    TextField("Nachricht", text: $text).textFieldStyle(.roundedBorder)
                    Button { store.send(text, rideID: ride.id, sender: auth.current?.displayName ?? ""); text = "" } label: {
                        Image(systemName: "paperplane.fill")
                    }
                }.padding()
            }
            .navigationTitle(ride.driverName)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Fertig") { dismiss() } } }
        }
    }
}
