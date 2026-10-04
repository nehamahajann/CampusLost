import SwiftUI

/// Lets a student manually search through everything reported found on
/// campus, for when they'd rather look themselves than wait for an
/// s
struct BrowseFoundItemsView: View {
    @State private var foundReports: [FoundReportItem] = []
    @State private var searchText = ""

    private let repository: LostFoundRepository = CoreDataLostFoundRepository()

    private var filteredReports: [FoundReportItem] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return foundReports }
        let query = searchText.lowercased()
        return foundReports.filter {
            $0.itemName.lowercased().contains(query) ||
            $0.category.lowercased().contains(query) ||
            $0.location.lowercased().contains(query)
        }
    }

    var body: some View {
        List {
            if filteredReports.isEmpty {
                ContentUnavailableView.search
            }
            ForEach(filteredReports) { report in
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(AppTheme.found.opacity(0.15)).frame(width: 40, height: 40)
                        Image(systemName: AppTheme.categoryIcon(report.category)).foregroundStyle(AppTheme.found)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(report.itemName).font(.body.weight(.medium))
                        Text("\(report.category) — \(report.location)").font(.caption).foregroundStyle(.secondary)
                        if !report.itemDescription.isEmpty {
                            Text(report.itemDescription).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }
                    Spacer()
                    Text(report.date, format: .dateTime.day().month(.abbreviated))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }

        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by item, category, or location")        .navigationTitle("Found items")
        .onAppear {
            foundReports = repository.allFoundReports()
        }
        .overlay {
            if foundReports.isEmpty {
                ContentUnavailableView("No found items yet", systemImage: "tray",
                    description: Text("When someone reports finding an item, it'll show up here."))
            }
        }
    }
}
