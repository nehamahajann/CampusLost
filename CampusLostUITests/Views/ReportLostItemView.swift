import SwiftUI

struct ReportLostItemView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var itemName = ""
    @State private var category = "Electronics"
    @State private var location = ""
    @State private var date = Date.now
    @State private var itemDescription = ""
    @State private var errorMessage: String?

    private let categories = ["Electronics", "Clothing", "Bag", "Keys", "ID/Cards", "Other"]
    private let repository: LostFoundRepository = CoreDataLostFoundRepository()

    var body: some View {
        Form {
            Section("Lost item") {
                TextField("Item name", text: $itemName)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0) }
                }
                TextField("Location (e.g. Building 11)", text: $location)
                DatePicker("Date lost", selection: $date, in: ...Date.now, displayedComponents: .date)
                TextField("Description", text: $itemDescription, axis: .vertical)
                    .lineLimit(3...6)
            }

            Button("Submit report", action: submit)
                .frame(maxWidth: .infinity)
        }
        .navigationTitle("Report lost item")
        .alert("Couldn't Submit", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func submit() {
        do {
            try ReportLostItemUseCase(repository: repository).execute(
                itemName: itemName, category: category, itemDescription: itemDescription,
                location: location, date: date
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
