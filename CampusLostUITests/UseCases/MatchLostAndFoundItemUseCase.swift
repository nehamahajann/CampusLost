import Foundation

enum ItemMatchingError: LocalizedError, Equatable {
    case noCandidatesFound
    case dateOutsideMatchingWindow(maxDays: Int)

    var errorDescription: String? {
        switch self {
        case .noCandidatesFound:
            return "No found items currently match this report's category and location. We'll keep checking as new items are reported."
        case .dateOutsideMatchingWindow(let maxDays):
            return "A found item exists for this category and location, but it was reported more than \(maxDays) days apart — too far apart to confidently call it a match."
        }
    }
}

/// Encapsulates the core business rule of CampusLost: deciding whether a
/// lost report and a found report are likely describing the same item.
struct MatchLostAndFoundItemUseCase {
    let repository: LostFoundRepository
    private let matchingWindowDays = 7

    /// Looks for a found report that could plausibly match the given lost
    /// report, and if one exists, creates a MatchRecord linking them.
    @discardableResult
    func execute(for lostReport: LostReportItem) throws -> MatchRecordItem {
        let candidates = repository.unmatchedFoundReports(
            category: lostReport.category,
            location: lostReport.location,
            around: lostReport.date,
            dayWindow: matchingWindowDays
        )

        guard let bestMatch = candidates.first else {
            throw ItemMatchingError.noCandidatesFound
        }

        let match = MatchRecordItem(
            id: UUID(), matchDate: .now, status: "pending_review",
            lostReportID: lostReport.id, foundReportID: bestMatch.id
        )
        try repository.saveMatch(match)
        return match
    }
}
