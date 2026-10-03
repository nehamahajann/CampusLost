import SwiftUI

struct MatchReviewView: View {
    @State private var matches: [MatchRecordItem] = []
    @State private var lostReports: [LostReportItem] = []
    @State private var foundReports: [FoundReportItem] = []

    private let repository: LostFoundRepository = CoreDataLostFoundRepository()

    var body: some View {
        List {
            if pendingMatches.isEmpty {
                ContentUnavailableView("No matches yet", systemImage: "checkmark.circle",
                    description: Text("We'll let you know when a found item matches one of your lost reports."))
            }
            ForEach(pendingMatches) { match in
                matchCard(for: match)
            }
        }
        .navigationTitle("Possible matches")
        .onAppear(perform: reload)
    }

    private var pendingMatches: [MatchRecordItem] {
        matches.filter { $0.status == "pending_review" }
    }

    private func matchCard(for match: MatchRecordItem) -> some View {
        let lost = lostReports.first { $0.id == match.lostReportID }
        let found = foundReports.first { $0.id == match.foundReportID }

        return VStack(alignment: .leading, spacing: 10) {
            Label("Possible match found", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.headline)

            if let lost {
                infoBlock(label: "You lost", text: "\(lost.itemName) — \(lost.location)")
            }
            if let found {
                infoBlock(label: "Someone found", text: "\(found.itemName) — \(found.location)")
            }

            HStack {
                Button("Confirm, this is mine") { updateStatus(match.id, to: "confirmed") }
                    .buttonStyle(.borderedProminent)
                Button("Not my item") { updateStatus(match.id, to: "rejected") }
                    .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 6)
    }

    private func infoBlock(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(text)
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
    }
}
