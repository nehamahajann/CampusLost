import SwiftUI

struct MyReportsView: View {
    @State private var lostReports: [LostReportItem] = []
    @State private var foundReports: [FoundReportItem] = []
    @State private var matchMessage: String?

    private let repository: LostFoundRepository = CoreDataLostFoundRepository()

    var body: some View {
        List {
            Section("Lost") {
                if lostReports.isEmpty {
                    Text("No lost reports yet").foregroundStyle(.secondary)
                }
                ForEach(lostReports) { report in
                    reportRow(name: report.itemName, subtitle: "Lost — \(report.location)", status: report.status)
                }
            }
            Section("Found") {
                if foundReports.isEmpty {
                    Text("No found reports yet").foregroundStyle(.secondary)
                }
                ForEach(foundReports) { report in
                    reportRow(name: report.itemName, subtitle: "Found — \(report.location)", status: report.status)
                }
            }
        }
        .navigationTitle("My reports")
        .toolbar {
            NavigationLink("Check matches") { MatchReviewView() }
        }
        .onAppear(perform: reload)
        .alert("Matching", isPresented: Binding(get: { matchMessage != nil }, set: { if !$0 { matchMessage = nil } })) {
            Button("OK", role: .cancel) { matchMessage = nil }
        } message: {
            Text(matchMessage ?? "")
        }
    }

    private func reportRow(name: String, subtitle: String, status: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(status.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(Color(.systemGray5)))
        }
    }

    private func reload() {
        lostReports = repository.allLostReports()
        foundReports = repository.allFoundReports()

//        for lost in lostReports where lost.status == "unmatched" {
//            try? MatchLostAndFoundItemUseCase(repository: repository).execute(for: lost)
//        }
//        
        for lost in lostReports where lost.status == "unmatched" {
            _ = try? MatchLostAndFoundItemUseCase(repository: repository).execute(for: lost)
        }
    }
}
