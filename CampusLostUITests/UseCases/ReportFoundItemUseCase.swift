import Foundation

enum FoundItemReportingError: LocalizedError, Equatable {
    case emptyItemName
    case futureFoundDate
    case missingLocation

    var errorDescription: String? {
        switch self {
        case .emptyItemName:
            return "Give the item a name so a student searching for it can recognise it."
        case .futureFoundDate:
            return "The date you found this item can't be in the future."
        case .missingLocation:
            return "Add where you found it — this is how the app matches it to someone's lost report."
        }
    }
}

/// Handles someone reporting an item they've found on campus.
struct ReportFoundItemUseCase {
    let repository: LostFoundRepository

    func execute(
        itemName: String, category: String, itemDescription: String,
        location: String, date: Date
    ) throws {
        guard !itemName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw FoundItemReportingError.emptyItemName
        }
        guard date <= .now else {
            throw FoundItemReportingError.futureFoundDate
        }
        guard !location.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw FoundItemReportingError.missingLocation
        }

        let report = FoundReportItem(
            id: UUID(), itemName: itemName, category: category,
            itemDescription: itemDescription, location: location,
            date: date, status: "unmatched", createdAt: .now
        )
        try repository.saveFoundReport(report)
    }
}
