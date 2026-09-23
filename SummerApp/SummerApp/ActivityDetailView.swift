import SwiftUI

struct ActivityDetailView: View {
    @Environment(ActivityStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let activity: Activity

    @State private var editing = false
    @State private var confirmingDelete = false

    private var entry: Activity {
        store.activities.first { $0.id == activity.id } ?? activity
    }

    var body: some View {
        List {
            if !entry.photos.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(entry.photos.indices, id: \.self) { index in
                                PhotoImage(data: entry.photos[index])
                                    .frame(width: 220, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }

            Section {
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { value in
                        Image(systemName: value <= entry.rating ? "star.fill" : "star")
                            .foregroundStyle(.orange)
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("Rated \(entry.rating) out of 5")

                if !entry.note.isEmpty {
                    Text(entry.note)
                }
            }

            Section {
                LabeledContent("Place", value: entry.place)
                LabeledContent("Date", value: entry.date.dayAndMonth)
                LabeledContent("Category", value: entry.category.rawValue)
                if !entry.duration.isEmpty {
                    LabeledContent("Duration", value: entry.duration)
                }
                if !entry.weather.isEmpty {
                    LabeledContent("Weather", value: entry.weather)
                }
            }

            Section {
                Button("Delete Entry", role: .destructive) {
                    confirmingDelete = true
                }
            }
        }
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") { editing = true }
        }
        .sheet(isPresented: $editing) {
            ActivityFormView(activity: entry)
        }
        .confirmationDialog("Delete this entry?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete(entry)
                dismiss()
            }
        }
    }
}
