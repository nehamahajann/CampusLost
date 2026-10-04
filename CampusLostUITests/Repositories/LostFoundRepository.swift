import Foundation

/// A lost item report, independent of how it's stored — Use Cases and Views
/// only ever see this struct, never Core Data's generated classes.
struct LostReportItem: Identifiable, Equatable {
    let id: UUID
    var itemName: String
    var category: String
    var itemDescription: String
    var location: String
    var date: Date
    var status: String
    var createdAt: Date
}

struct FoundReportItem: Identifiable, Equatable {
    let id: UUID
    var itemName: String
    var category: String
    var itemDescription: String
    var location: String
    var date: Date
    var status: String
    var createdAt: Date
}

struct MatchRecordItem: Identifiable, Equatable {
    let id: UUID
    var matchDate: Date
    var status: String
    var lostReportID: UUID
    var foundReportID: UUID
    var confidencePercent: Int
}

/// Abstracts all persistence for lost/found reports and matches behind a
/// protocol, so Use Cases never talk to Core Data directly, and tests can
/// swap in an in-memory mock instead of touching the real database.
protocol LostFoundRepository {
    func saveLostReport(_ report: LostReportItem) throws
    func saveFoundReport(_ report: FoundReportItem) throws
    func allLostReports() -> [LostReportItem]
    func allFoundReports() -> [FoundReportItem]

    /// The core domain query: found reports that could plausibly match a
    /// given lost report — same category, same location, found within
    /// `dayWindow` days of the lost date, and not already matched.
    func unmatchedFoundReports(category: String, location: String, around date: Date, dayWindow: Int) -> [FoundReportItem]

    func saveMatch(_ match: MatchRecordItem) throws
    func allMatches() -> [MatchRecordItem]
    func updateMatchStatus(id: UUID, status: String) throws
}
