import SwiftUI

struct NewEntryView: View {
    @Environment(SummerStore.self) private var store
    var onSave: () -> Void

    @State private var title = ""
    @State private var place = ""
    @State private var date = Date()
    @State private var category = Category.wassersport
    @State private var region = Region.zuhause
    @State private var rating = 5
    @State private var note = ""

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Field(label: "Was hast du gemacht") {
                        TextField("Jetski am Vai Beach", text: $title)
                    }
                    Field(label: "Ort") {
                        TextField("Vai, Kreta", text: $place)
                    }
                    Field(label: "Datum") {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                    Field(label: "Kategorie") {
                        Picker("", selection: $category) {
                            ForEach(Category.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .labelsHidden()
                    }
                    Field(label: "Wo") {
                        Picker("", selection: $region) {
                            ForEach(Region.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wie war es")
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
                                .accessibilityLabel("\(value) von 5")
                            }
                        }
                    }

                    Field(label: "Notiz") {
                        TextEditor(text: $note)
                            .frame(height: 96)
                            .scrollContentBackground(.hidden)
                    }
                }
                .padding(20)
            }
            .background(Theme.sand)
            .navigationTitle("Neuer Eintrag")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { saveBar }
        }
    }

    private var saveBar: some View {
        Button(action: save) {
            Text("Speichern")
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

    private func save() {
        store.add(
            Activity(
                title: title,
                place: place.isEmpty ? "[DEIN ORT]" : place,
                date: date,
                category: category,
                region: region,
                rating: rating,
                note: note
            )
        )
        title = ""
        place = ""
        note = ""
        rating = 5
        onSave()
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
