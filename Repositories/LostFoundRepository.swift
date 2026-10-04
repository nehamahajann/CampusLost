import Foundation

/// A student's report of an item they've lost on campus — what it is,
/// where and when it went missing, and whether it's been matched yet.
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
/// An item someone has found on campus and reported, so its rightful
/// owner can be matched to it automatically.
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

/// Links a lost report to a found report the system believes describes
/// the same item, along with how confident that guess is and whether
/// the student has confirmed or rejected it.

struct MatchRecordItem: Identifiable, Equatable {
    let id: UUID
    var matchDate: Date
    var status: String
    var lostReportID: UUID
    var foundReportID: UUID
    var confidencePercent: Int
}

protocol LostFoundRepository {
    func saveLostReport(_ report: LostReportItem) throws
    func saveFoundReport(_ report: FoundReportItem) throws
    func allLostReports() -> [LostReportItem]
    func allFoundReports() -> [FoundReportItem]


    /// `dayWindow` days of the lost date, and not already matched.
    func unmatchedFoundReports(category: String, location: String, around date: Date, dayWindow: Int) -> [FoundReportItem]

    func saveMatch(_ match: MatchRecordItem) throws
    func allMatches() -> [MatchRecordItem]
    func updateMatchStatus(id: UUID, status: String) throws
}
