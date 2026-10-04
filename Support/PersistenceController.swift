//import CoreData
//
///// Owns the Core Data stack for CampusLost. A single shared instance is used
///// by the app; a separate in-memory instance exists for previews/tests so
///// test data never touches the real on-disk store.
//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    let container: NSPersistentContainer
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentContainer(name: "CampusLost")
//        if inMemory {
//            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
//        }
//        container.loadPersistentStores { _, error in
//            if let error {
//                fatalError("Failed to load Core Data store: \(error)")
//            }
//        }
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
//}


import CoreData

/// Owns the Core Data stack for CampusLost. The database file is stored in
/// the shared App Group container (not the app's private sandbox) so the
/// Widget extension can read the same data the main app writes.
struct PersistenceController {
    static let shared = PersistenceController()

    static let appGroupID = "group.Neha.CampusLost"

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CampusLost")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID) {
            let storeURL = groupURL.appendingPathComponent("CampusLost.sqlite")
            container.persistentStoreDescriptions.first?.url = storeURL
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
