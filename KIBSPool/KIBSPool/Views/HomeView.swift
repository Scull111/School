import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var store: RideStore
    var goToRides: () -> Void

    static let kibs = CLLocationCoordinate2D(latitude: 52.3759, longitude: 9.7320)
    @State private var showProfile = false
    @State private var showOffer = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Static map, user location is never requested.
                Map(initialPosition: .region(.init(center: Self.kibs,
                                                   span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02))),
                    interactionModes: [.pan, .zoom]) {
                    Marker("KIBS Hannover", systemImage: "graduationcap.fill", coordinate: Self.kibs).tint(Theme.green)
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .ignoresSafeArea(edges: .top)

                VStack(spacing: 12) {
                    Button(action: goToRides) {
                        HStack { Image(systemName: "magnifyingglass").foregroundStyle(Theme.green)
                            Text("Wohin ab der Schule?").foregroundStyle(.secondary); Spacer() }
                            .font(.title3).padding(16)
                            .background(.background, in: Capsule()).shadow(radius: 4)
                    }
                    HStack {
                        quick("Nach Hause", "house") { goToRides() }
                        Divider().frame(height: 40)
                        quick("Fahrt anbieten", "plus.circle") { showOffer = true }
                    }.card()
                    if let ride = store.bookedRide {
                        NavigationLink { ActiveRideView(ride: ride) } label: { departureRow(ride) }
                            .buttonStyle(.plain)
                    } else {
                        Button(action: goToRides) { departureRow(nil) }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 8)
            }
            .navigationTitle("KIBS Pool")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showProfile = true } label: { Image(systemName: "person.circle") }
                }
            }
            .sheet(isPresented: $showProfile) { AccountView() }
            .sheet(isPresented: $showOffer) { OfferRideView() }
        }
    }

    private func quick(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).font(.title2).foregroundStyle(Theme.green)
                    .frame(width: 52, height: 52).background(Theme.greenSoft, in: Circle())
                Text(title).font(.headline)
            }.frame(maxWidth: .infinity)
        }.buttonStyle(.plain)
    }

    private func departureRow(_ ride: Ride?) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "clock").font(.title2).foregroundStyle(Theme.green)
                .frame(width: 52, height: 52).background(Theme.greenSoft, in: Circle())
            VStack(alignment: .leading) {
                Text(ride == nil ? "Abfahrt" : "Deine Fahrt").font(.subheadline).foregroundStyle(.secondary)
                Text(ride.map { DateFormatter.clock.string(from: $0.departure) + " Uhr" } ?? "7:30 Uhr").font(.title2.bold())
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(Theme.green)
        }.card()
    }
}
