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

    @discardableResult
    func execute(for lostReport: LostReportItem) throws -> MatchRecordItem {
        let candidates = repository.unmatchedFoundReports(
            category: lostReport.category,
            location: lostReport.location,
            around: lostReport.date,
            dayWindow: matchingWindowDays
        )

        guard !candidates.isEmpty else {
            throw ItemMatchingError.noCandidatesFound
        }

        let scored = candidates.map { found in
            (found: found, confidence: Self.confidence(lost: lostReport, found: found))
        }
        let best = scored.max { $0.confidence < $1.confidence }!

        let match = MatchRecordItem(
            id: UUID(), matchDate: .now, status: "pending_review",
            lostReportID: lostReport.id, foundReportID: best.found.id,
            confidencePercent: best.confidence
        )
        try repository.saveMatch(match)
        return match
    }

    /// A simple, explainable confidence score (0-100) for how likely a
    /// lost and found report describe the same item. Category, location,
    /// and date are already guaranteed to align by this point,
    
    static func confidence(lost: LostReportItem, found: FoundReportItem) -> Int {
        var score = 50 // baseline, since category/location/date already matched

        let lostName = lost.itemName.lowercased().trimmingCharacters(in: .whitespaces)
        let foundName = found.itemName.lowercased().trimmingCharacters(in: .whitespaces)

        if lostName == foundName {
            score += 35
        } else if lostName.contains(foundName) || foundName.contains(lostName) {
            score += 20
        }

        let lostWords = Set(lost.itemDescription.lowercased().split(separator: " ").map(String.init))
        let foundWords = Set(found.itemDescription.lowercased().split(separator: " ").map(String.init))
        if !lostWords.isEmpty && !foundWords.isEmpty {
            let overlap = lostWords.intersection(foundWords).count
            let bonus = min(15, overlap * 5)
            score += bonus
        }

        return min(100, score)
    }
}
