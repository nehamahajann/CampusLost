import Foundation

enum LostItemReportingError: LocalizedError, Equatable {
    case emptyItemName
    case futureLostDate
    case descriptionTooShort(minimumCharacters: Int)

    var errorDescription: String? {
        switch self {
        case .emptyItemName:
            return "Give your item a name so others can recognise it — for example, \"Blue water bottle\" rather than leaving this blank."
        case .futureLostDate:
            return "The date you lost this item can't be in the future. Pick the actual day it went missing."
        case .descriptionTooShort(let minimum):
            return "Add a bit more detail — at least \(minimum) characters — so a finder can tell your item apart from similar ones."
        }
    }
}

/// Handles a student reporting an item they've lost on campus, making sure
/// the report has enough real information to actually be matched later.
struct ReportLostItemUseCase {
    let repository: LostFoundRepository
    private let minimumDescriptionLength = 10

    func execute(
        itemName: String, category: String, itemDescription: String,
        location: String, date: Date
    ) throws {
        guard !itemName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw LostItemReportingError.emptyItemName
        }
        guard date <= .now else {
            throw LostItemReportingError.futureLostDate
        }
        guard itemDescription.trimmingCharacters(in: .whitespaces).count >= minimumDescriptionLength else {
            throw LostItemReportingError.descriptionTooShort(minimumCharacters: minimumDescriptionLength)
        }

        let report = LostReportItem(
            id: UUID(), itemName: itemName, category: category,
            itemDescription: itemDescription, location: location,
            date: date, status: "unmatched", createdAt: .now
        )
        try repository.saveLostReport(report)
    }
}
