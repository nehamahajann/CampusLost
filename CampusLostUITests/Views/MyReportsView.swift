import SwiftUI
import WidgetKit
import UserNotifications

struct MyReportsView: View {
    @State private var lostReports: [LostReportItem] = []
    @State private var foundReports: [FoundReportItem] = []
    @State private var pendingMatchCount = 0

    private let repository: LostFoundRepository = CoreDataLostFoundRepository()

    var body: some View {
        List {
            Section {
                if lostReports.isEmpty {
                    Text("No lost reports yet").foregroundStyle(.secondary)
                }
                ForEach(lostReports) { report in
                    reportRow(name: report.itemName, category: report.category,
                              subtitle: report.location, status: report.status, tint: AppTheme.lost)
                }
            } header: {
                Label("Lost", systemImage: "questionmark.circle.fill").foregroundStyle(AppTheme.lost)
            }

            Section {
                if foundReports.isEmpty {
                    Text("No found reports yet").foregroundStyle(.secondary)
                }
                ForEach(foundReports) { report in
                    reportRow(name: report.itemName, category: report.category,
                              subtitle: report.location, status: report.status, tint: AppTheme.found)
                }
            } header: {
                Label("Found", systemImage: "checkmark.circle.fill").foregroundStyle(AppTheme.found)
            }
        }
        .navigationTitle("My reports")
        .toolbar {
            NavigationLink {
                MatchReviewView()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "checklist")
                    Text("Matches")
                    if pendingMatchCount > 0 {
                        Text("\(pendingMatchCount)")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(AppTheme.pending))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .onAppear(perform: reload)
    }

    private func reportRow(name: String, category: String, subtitle: String, status: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(tint.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: AppTheme.categoryIcon(category)).foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.body.weight(.medium))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(status.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(AppTheme.statusColor(status).opacity(0.15)))
                .foregroundStyle(AppTheme.statusColor(status))
        }
        .padding(.vertical, 4)
    }

    private func reload() {
        lostReports = repository.allLostReports()
        foundReports = repository.allFoundReports()
        pendingMatchCount = repository.allMatches().filter { $0.status == "pending_review" }.count

        for lost in lostReports where lost.status == "unmatched" {
            if let match = try? MatchLostAndFoundItemUseCase(repository: repository).execute(for: lost) {
                scheduleMatchNotification(for: lost, match: match)
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func scheduleMatchNotification(for lost: LostReportItem, match: MatchRecordItem) {
        let content = UNMutableNotificationContent()
        content.title = "Possible match found!"
        content.body = "\(lost.itemName) may have been found near \(lost.location)."
        content.categoryIdentifier = "MATCH_FOUND"
        content.userInfo = ["lostItemName": lost.itemName, "foundLocation": lost.location]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: match.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
