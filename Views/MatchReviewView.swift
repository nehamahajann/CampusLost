import SwiftUI
import WidgetKit

struct MatchReviewView: View {
    @State private var matches: [MatchRecordItem] = []
    @State private var lostReports: [LostReportItem] = []
    @State private var foundReports: [FoundReportItem] = []
    @State private var showPickupInstructions = false

    private let repository: LostFoundRepository = CoreDataLostFoundRepository()

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if pendingMatches.isEmpty {
                    ContentUnavailableView("No matches yet", systemImage: "checkmark.circle",
                        description: Text("We'll let you know when a found item matches one of your lost reports."))
                        .padding(.top, 60)
                }
                ForEach(pendingMatches) { match in
                    matchCard(for: match)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Possible matches")
        .onAppear(perform: reload)
        .alert("Match Confirmed!", isPresented: $showPickupInstructions) {
            Button("OK") {}
        } message: {
            Text("Great news! head to UTS Security (Building 1, Ground Floor) with your student ID to collect your item. They hold all confirmed found items on campus.")
        }
    }

    private var pendingMatches: [MatchRecordItem] {
        matches.filter { $0.status == "pending_review" }
    }

    private func matchCard(for match: MatchRecordItem) -> some View {
        let lost = lostReports.first { $0.id == match.lostReportID }
        let found = foundReports.first { $0.id == match.foundReportID }

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Possible match found", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(AppTheme.pending)
                Spacer()
                Text("\(match.confidencePercent)% match")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(confidenceColor(match.confidencePercent).opacity(0.15)))
                    .foregroundStyle(confidenceColor(match.confidencePercent))
            }

            if let lost {
                infoBlock(icon: "questionmark.circle.fill", color: AppTheme.lost,
                          label: "You lost", text: "\(lost.itemName) — \(lost.location)")
            }
            if let found {
                infoBlock(icon: "checkmark.circle.fill", color: AppTheme.found,
                          label: "Someone found", text: "\(found.itemName) — \(found.location)")
            }

            HStack(spacing: 10) {
                Button("Confirm, this is mine") {
                    updateStatus(match.id, to: "confirmed")
                    showPickupInstructions = true
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.matched)
                Button("Not my item") { updateStatus(match.id, to: "rejected") }
                    .buttonStyle(.bordered)
            }
        }
        .cardStyle()
    }

    private func infoBlock(icon: String, color: Color, label: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Text(text).font(.subheadline)
            }
        }
    }

    private func reload() {
        matches = repository.allMatches()
        lostReports = repository.allLostReports()
        foundReports = repository.allFoundReports()
    }

    private func updateStatus(_ id: UUID, to status: String) {
        try? repository.updateMatchStatus(id: id, status: status)
        reload()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func confidenceColor(_ percent: Int) -> Color {
        switch percent {
        case 80...: return AppTheme.matched
        case 60..<80: return AppTheme.pending
        default: return .secondary
        }
    }
}
