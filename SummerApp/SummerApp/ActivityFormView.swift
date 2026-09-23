import SwiftUI
import PhotosUI

struct ActivityFormView: View {
    @Environment(ActivityStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private let isEditing: Bool

    @State private var draft: Activity
    @State private var picked: [PhotosPickerItem] = []

    init(activity: Activity? = nil) {
        isEditing = activity != nil
        _draft = State(initialValue: activity ?? Activity(
            title: "",
            place: "",
            date: .now,
            category: .watersports,
            region: .home,
            rating: 5,
            note: ""
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What did you do", text: $draft.title)
                    TextField("Place", text: $draft.place)
                    DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                    Picker("Category", selection: $draft.category) {
                        ForEach(Category.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    Picker("Where", selection: $draft.region) {
                        ForEach(Region.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Rating") {
                    HStack(spacing: 3) {
                        ForEach(1...5, id: \.self) { value in
                            Button {
                                draft.rating = value
                            } label: {
                                Image(systemName: value <= draft.rating ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel("\(value) out of 5")
                        }
                    }
                }

                Section("Photos") {
                    if !draft.photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(draft.photos.indices, id: \.self) { index in
                                    PhotoImage(data: draft.photos[index])
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(alignment: .topTrailing) {
                                            Button {
                                                draft.photos.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.white, .black.opacity(0.6))
                                                    .padding(4)
                                            }
                                            .buttonStyle(.borderless)
                                            .accessibilityLabel("Remove photo \(index + 1)")
                                        }
                                }
                            }
                        }
                    }

                    PhotosPicker("Add Photos", selection: $picked, maxSelectionCount: 5, matching: .images)
                        .onChange(of: picked) { _, items in
                            Task { await loadPhotos(items) }
                        }
                }

                Section("Note") {
                    TextField("How was it", text: $draft.note, axis: .vertical)
                        .lineLimit(3...)
                }

                Section("Details") {
                    TextField("Duration", text: $draft.duration)
                    TextField("Weather", text: $draft.weather)
                }
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    @MainActor
    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                draft.photos.append(data)
            }
        }
        picked = []
    }

    private func save() {
        if draft.place.isEmpty {
            draft.place = "[YOUR PLACE]"
        }
        if isEditing {
            store.update(draft)
        } else {
            store.add(draft)
        }
        dismiss()
    }
}
