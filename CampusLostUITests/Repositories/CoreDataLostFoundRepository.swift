import CoreData
import Foundation

/// The real, on-device implementation of LostFoundRepository, backed by
/// Core Data. Converts between Core Data's generated NSManagedObject
/// classes and the plain structs the rest of the app works with.
final class CoreDataLostFoundRepository: LostFoundRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func saveLostReport(_ report: LostReportItem) throws {
        let entity = LostReport(context: context)
        entity.id = report.id
        entity.itemName = report.itemName
        entity.category = report.category
        entity.itemDescription = report.itemDescription
        entity.location = report.location
        entity.date = report.date
        entity.status = report.status
        entity.createdAt = report.createdAt
        try context.save()
    }

    func saveFoundReport(_ report: FoundReportItem) throws {
        let entity = FoundReport(context: context)
        entity.id = report.id
        entity.itemName = report.itemName
        entity.category = report.category
        entity.itemDescription = report.itemDescription
        entity.location = report.location
        entity.date = report.date
        entity.status = report.status
        entity.createdAt = report.createdAt
        try context.save()
    }

    func allLostReports() -> [LostReportItem] {
        let request = LostReport.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let results = (try? context.fetch(request)) ?? []
        return results.compactMap(Self.toItem)
    }

    func allFoundReports() -> [FoundReportItem] {
        let request = FoundReport.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let results = (try? context.fetch(request)) ?? []
        return results.compactMap(Self.toItem)
    }

    func unmatchedFoundReports(category: String, location: String, around date: Date, dayWindow: Int) -> [FoundReportItem] {
        let request = FoundReport.fetchRequest()
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -dayWindow, to: date) ?? date
        let end = calendar.date(byAdding: .day, value: dayWindow, to: date) ?? date

        request.predicate = NSPredicate(
            format: "category == %@ AND location == %@ AND date >= %@ AND date <= %@ AND status == %@",
            category, location, start as NSDate, end as NSDate, "unmatched"
        )
        let results = (try? context.fetch(request)) ?? []
        return results.compactMap(Self.toItem)
    }

    func saveMatch(_ match: MatchRecordItem) throws {
        let entity = MatchRecord(context: context)
        entity.id = match.id
        entity.matchDate = match.matchDate
        entity.status = match.status

        let lostRequest = LostReport.fetchRequest()
        lostRequest.predicate = NSPredicate(format: "id == %@", match.lostReportID as CVarArg)
        if let lostEntity = try context.fetch(lostRequest).first {
            entity.lostReport = lostEntity
        }

        let foundRequest = FoundReport.fetchRequest()
        foundRequest.predicate = NSPredicate(format: "id == %@", match.foundReportID as CVarArg)
        if let foundEntity = try context.fetch(foundRequest).first {
            entity.foundReport = foundEntity
        }

        try context.save()
    }

    func allMatches() -> [MatchRecordItem] {
        let request = MatchRecord.fetchRequest()
        let results = (try? context.fetch(request)) ?? []
        return results.compactMap(Self.toItem)
    }

    func updateMatchStatus(id: UUID, status: String) throws {
        let request = MatchRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let entity = try context.fetch(request).first else { return }
        entity.status = status
        try context.save()
    }

    private static func toItem(_ entity: LostReport) -> LostReportItem? {
        guard let id = entity.id, let itemName = entity.itemName, let category = entity.category,
              let location = entity.location, let date = entity.date,
              let status = entity.status, let createdAt = entity.createdAt else { return nil }
        return LostReportItem(
            id: id, itemName: itemName, category: category,
            itemDescription: entity.itemDescription ?? "", location: location,
            date: date, status: status, createdAt: createdAt
        )
    }

    private static func toItem(_ entity: FoundReport) -> FoundReportItem? {
        guard let id = entity.id, let itemName = entity.itemName, let category = entity.category,
              let location = entity.location, let date = entity.date,
              let status = entity.status, let createdAt = entity.createdAt else { return nil }
        return FoundReportItem(
            id: id, itemName: itemName, category: category,
            itemDescription: entity.itemDescription ?? "", location: location,
            date: date, status: status, createdAt: createdAt
        )
    }

    private static func toItem(_ entity: MatchRecord) -> MatchRecordItem? {
        guard let id = entity.id, let matchDate = entity.matchDate, let status = entity.status,
              let lostID = entity.lostReport?.id, let foundID = entity.foundReport?.id else { return nil }
        return MatchRecordItem(id: id, matchDate: matchDate, status: status, lostReportID: lostID, foundReportID: foundID)
    }
}
