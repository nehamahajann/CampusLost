import WidgetKit
import SwiftUI

struct ReportStatusEntry: TimelineEntry {
    let date: Date
    let itemName: String
    let status: String
}

struct ReportStatusProvider: TimelineProvider {
    private let repository: LostFoundRepository = CoreDataLostFoundRepository()

    func placeholder(in context: Context) -> ReportStatusEntry {
        ReportStatusEntry(date: .now, itemName: "AirPods", status: "unmatched")
    }

    func getSnapshot(in context: Context, completion: @escaping (ReportStatusEntry) -> Void) {
        completion(latestEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReportStatusEntry>) -> Void) {
        let entry = latestEntry()
        let timeline = Timeline(entries: [entry], policy: .after(Date.now.addingTimeInterval(15 * 60)))
        completion(timeline)
    }

    private func latestEntry() -> ReportStatusEntry {
        let reports = repository.allLostReports()
        guard let latest = reports.first else {
            return ReportStatusEntry(date: .now, itemName: "No active reports", status: "none")
        }
        return ReportStatusEntry(date: .now, itemName: latest.itemName, status: latest.status)
    }
}

struct CampusLostWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: ReportStatusProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        default:
            mediumView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(entry.itemName)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
            Text(statusLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 4) {
                Text("Your lost item").font(.caption).foregroundStyle(.secondary)
                Text(entry.itemName).font(.headline)
                Text(statusLabel).font(.subheadline).foregroundStyle(color)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var icon: String {
        switch entry.status {
        case "none": return "tray"
        case "unmatched": return "magnifyingglass"
        case "pending_review": return "exclamationmark.circle"
        case "confirmed": return "checkmark.circle.fill"
        default: return "questionmark.circle"
        }
    }

    private var color: Color {
        switch entry.status {
        case "confirmed": return .green
        case "pending_review": return .orange
        case "none": return .secondary
        default: return .blue
        }
    }

    private var statusLabel: String {
        switch entry.status {
        case "none": return "No active reports"
        case "unmatched": return "No match yet"
        case "pending_review": return "Match found!"
        case "confirmed": return "Confirmed"
        default: return entry.status.capitalized
        }
    }
}

struct CampusLostWidget: Widget {
    let kind: String = "CampusLostWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReportStatusProvider()) { entry in
            CampusLostWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("CampusLost Status")
        .description("See the status of your most recent lost item report.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    CampusLostWidget()
} timeline: {
    ReportStatusEntry(date: .now, itemName: "AirPods", status: "pending_review")
}
