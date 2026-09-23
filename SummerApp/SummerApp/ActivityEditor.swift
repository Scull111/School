import SwiftUI
import PhotosUI

struct ActivityEditor: View {
    @Environment(SummerStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let activity: Activity?
    var onFinish: () -> Void = {}

    @State private var title: String
    @State private var place: String
    @State private var date: Date
    @State private var category: Category
    @State private var region: Region
    @State private var rating: Int
    @State private var note: String
    @State private var duration: String
    @State private var company: String
    @State private var weather: String
    @State private var photoNames: [String]
    @State private var picked: [PhotosPickerItem] = []
    @State private var confirmingDelete = false

    init(activity: Activity? = nil, onFinish: @escaping () -> Void = {}) {
        self.activity = activity
        self.onFinish = onFinish
        _title = State(initialValue: activity?.title ?? "")
        _place = State(initialValue: activity?.place ?? "")
        _date = State(initialValue: activity?.date ?? .now)
        _category = State(initialValue: activity?.category ?? .watersports)
        _region = State(initialValue: activity?.region ?? .home)
        _rating = State(initialValue: activity?.rating ?? 5)
        _note = State(initialValue: activity?.note ?? "")
        _duration = State(initialValue: activity?.duration ?? "")
        _company = State(initialValue: activity?.company ?? "")
        _weather = State(initialValue: activity?.weather ?? "")
        _photoNames = State(initialValue: activity?.photoNames ?? [])
    }

    private var isEditing: Bool { activity != nil }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Field(label: "What did you do") {
                        TextField("Jet ski at Vai Beach", text: $title)
                    }
                    Field(label: "Place") {
                        TextField("Vai, Crete", text: $place)
                    }
                    Field(label: "Date") {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                    Field(label: "Category") {
                        Picker("", selection: $category) {
                            ForEach(Category.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .labelsHidden()
                    }
                    Field(label: "Where") {
                        Picker("", selection: $region) {
                            ForEach(Region.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    stars
                    photoSection

                    Field(label: "Note") {
                        TextEditor(text: $note)
                            .frame(height: 96)
                            .scrollContentBackground(.hidden)
                    }
                    Field(label: "Duration") {
                        TextField("30 minutes", text: $duration)
                    }
                    Field(label: "With") {
                        TextField("Who were you with", text: $company)
                    }
                    Field(label: "Weather") {
                        TextField("Sunny, 31 degrees", text: $weather)
                    }

                    if isEditing {
                        deleteButton
                    }
                }
                .padding(20)
            }
            .background(Theme.sand)
            .navigationTitle(isEditing ? "Edit entry" : "New entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                        .foregroundStyle(Theme.muted)
                }
            }
            .safeAreaInset(edge: .bottom) { saveBar }
        }
    }

    private var stars: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("How was it")
                .eyebrow()
                .foregroundStyle(Theme.muted)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        rating = value
                    } label: {
                        Image(systemName: value <= rating ? "star.fill" : "star")
                            .font(.system(size: 26))
                            .foregroundStyle(value <= rating ? Theme.clay : Theme.line)
                            .frame(width: 46, height: 46)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(value) out of 5")
                }
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photos")
                .eyebrow()
                .foregroundStyle(Theme.muted)

            if !photoNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(photoNames.enumerated()), id: \.element) { index, name in
                            PhotoThumb(name: name)
                                .frame(width: 92, height: 92)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        photoNames.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 26, height: 26)
                                            .background(Theme.ink.opacity(0.75), in: Circle())
                                            .frame(width: 44, height: 44)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Remove photo \(index + 1)")
                                    .offset(x: 12, y: -12)
                                }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.trailing, 12)
                }
            }

            PhotosPicker(selection: $picked, maxSelectionCount: 6, matching: .images) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 17))
                    Text(photoNames.isEmpty ? "Add photos from your library" : "Add more photos")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Theme.placeholder, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Theme.line, style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
                }
            }
            .onChange(of: picked) { _, items in
                guard !items.isEmpty else { return }
                Task { await load(items) }
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            confirmingDelete = true
        } label: {
            Text("Delete entry")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.red)
        .cardBackground()
        .confirmationDialog("Delete this entry?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: deleteActivity)
            Button("Keep it", role: .cancel) { }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var saveBar: some View {
        Button(action: save) {
            Text(isEditing ? "Save changes" : "Save")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(isValid ? Theme.clay : Theme.muted.opacity(0.4), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isValid)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Theme.card)
    }

    @MainActor
    private func load(_ items: [PhotosPickerItem]) async {
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            if let name = PhotoStore.save(data) {
                photoNames.append(name)
            }
        }
        picked = []
    }

    private func save() {
        if var edited = activity {
            edited.title = title
            edited.place = place.isEmpty ? "[YOUR PLACE]" : place
            edited.date = date
            edited.category = category
            edited.region = region
            edited.rating = rating
            edited.note = note
            edited.duration = duration
            edited.company = company
            edited.weather = weather
            edited.photoNames = photoNames
            store.update(edited)
        } else {
            store.add(
                Activity(
                    title: title,
                    place: place.isEmpty ? "[YOUR PLACE]" : place,
                    date: date,
                    category: category,
                    region: region,
                    rating: rating,
                    note: note,
                    duration: duration,
                    weather: weather,
                    company: company,
                    photoNames: photoNames
                )
            )
            reset()
        }
        finish()
    }

    private func deleteActivity() {
        if let activity {
            store.delete(activity)
        }
        finish()
    }

    private func cancel() {
        if !isEditing {
            reset()
        }
        finish()
    }

    private func finish() {
        onFinish()
        dismiss()
    }

    private func reset() {
        title = ""
        place = ""
        date = .now
        category = .watersports
        region = .home
        rating = 5
        note = ""
        duration = ""
        company = ""
        weather = ""
        photoNames = []
    }
}

struct Field<Content: View>: View {
    let label: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .eyebrow()
                .foregroundStyle(Theme.muted)
            content
                .font(.system(size: 15))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardBackground(radius: 14)
        }
    }
}
