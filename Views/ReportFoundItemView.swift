import SwiftUI
import PhotosUI

struct ReportFoundItemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationService = CampusLocationService()

    var sharedPhoto: UIImage? = nil

    @State private var itemName = ""
    @State private var category = "Electronics"
    @State private var location = ""
    @State private var date = Date.now
    @State private var itemDescription = ""
    @State private var errorMessage: String?
    @State private var didSave = false

    @State private var photoItem: PhotosPickerItem?
    @State private var selectedPhoto: UIImage?
    @State private var suggestedCategory: String?
    @State private var isAnalyzingPhoto = false

    private let categories = ["Electronics", "Clothing", "Bag", "Keys", "ID/Cards", "Other"]
    private let repository: LostFoundRepository = CoreDataLostFoundRepository()

    var body: some View {
        Form {
            Section {
                if let photo = selectedPhoto ?? sharedPhoto {
                    Image(uiImage: photo)
                        .resizable().scaledToFit()
                        .frame(maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity)
                }

                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label(selectedPhoto == nil ? "Add a photo" : "Change photo", systemImage: "camera")
                }
                .onChange(of: photoItem) { _, newItem in
                    Task { await loadAndAnalyzePhoto(newItem) }
                }

                if isAnalyzingPhoto {
                    HStack {
                        ProgressView()
                        Text("Analyzing photo...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let suggestedCategory, suggestedCategory != category {
                    Button {
                        category = suggestedCategory
                        self.suggestedCategory = nil
                    } label: {
                        Label("AI suggests: \(suggestedCategory) — tap to use", systemImage: "sparkles")
                            .font(.caption)
                    }
                }
            }

            Section {
                TextField("Item name", text: $itemName)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Label(cat, systemImage: AppTheme.categoryIcon(cat)).tag(cat)
                    }
                }
                TextField("Location found", text: $location)
                if let suggested = locationService.suggestedBuilding, location.isEmpty {
                    Button {
                        location = suggested
                    } label: {
                        Label("Use detected location: \(suggested)", systemImage: "location.fill")
                            .font(.caption)
                    }
                }
                DatePicker("Date found", selection: $date, in: ...Date.now, displayedComponents: .date)
                TextField("Description", text: $itemDescription, axis: .vertical)
                    .lineLimit(3...6)
            } header: {
                Label("What did you find?", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.found)
            }

            Section {
                Button(action: submit) {
                    Text("Submit report").frame(maxWidth: .infinity).fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.found)
            }
        }
        .navigationTitle("Report found item")
        .onAppear { locationService.requestLocation() }
        .alert("Couldn't Submit", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
        .alert("Report Submitted", isPresented: $didSave) {
            Button("OK") { dismiss() }
        } message: { Text("Thanks for helping! Your found item report has been saved and we'll check for a matching lost report.") }
    }

    private func submit() {
        do {
            try ReportFoundItemUseCase(repository: repository).execute(
                itemName: itemName, category: category, itemDescription: itemDescription,
                location: location, date: date
            )
            SharedPhotoStore.clearPendingPhoto()
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func loadAndAnalyzePhoto(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }

        selectedPhoto = image
        isAnalyzingPhoto = true
        suggestedCategory = await PhotoClassificationService.suggestCategory(for: image)
        isAnalyzingPhoto = false
    }
}
