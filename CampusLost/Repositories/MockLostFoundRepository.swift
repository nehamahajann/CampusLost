import Foundation

/// An in-memory stand-in for LostFoundRepository, used only in unit tests —
/// no Core Data stack involved at all, so tests run fast and in isolation.
final class MockLostFoundRepository: LostFoundRepository {
    var lostReports: [LostReportItem] = []
    var foundReports: [FoundReportItem] = []
    var matches: [MatchRecordItem] = []

    func saveLostReport(_ report: LostReportItem) throws { lostReports.append(report) }
    func saveFoundReport(_ report: FoundReportItem) throws { foundReports.append(report) }
    func allLostReports() -> [LostReportItem] { lostReports }
    func allFoundReports() -> [FoundReportItem] { foundReports }

    func unmatchedFoundReports(category: String, location: String, around date: Date, dayWindow: Int) -> [FoundReportItem] {
        let calendar = Calendar.current
        return foundReports.filter { report in
            report.category == category &&
            report.location == location &&
            report.status == "unmatched" &&
            abs(calendar.dateComponents([.day], from: date, to: report.date).day ?? Int.max) <= dayWindow
        }
    }

    func saveMatch(_ match: MatchRecordItem) throws { matches.append(match) }
    func allMatches() -> [MatchRecordItem] { matches }
    func updateMatchStatus(id: UUID, status: String) throws {
        guard let index = matches.firstIndex(where: { $0.id == id }) else { return }
        matches[index].status = status
    }
}
