import SwiftUI
import CoreData


@main
struct CampusLostApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
