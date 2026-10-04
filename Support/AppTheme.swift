import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.25, green: 0.45, blue: 0.85)
    static let lost = Color(red: 0.16, green: 0.45, blue: 0.85)
    static let found = Color(red: 0.55, green: 0.35, blue: 0.80)
    static let matched = Color(red: 0.30, green: 0.70, blue: 0.40)
    static let pending = Color(red: 0.90, green: 0.60, blue: 0.15)
    static let unmatched = Color(.systemGray)

    static let cardRadius: CGFloat = 16

    static func statusColor(_ status: String) -> Color {
        switch status {
        case "confirmed": return matched
        case "pending_review": return pending
        case "rejected": return .secondary
        default: return unmatched
        }
    }

    static func categoryIcon(_ category: String) -> String {
        switch category {
        case "Electronics": return "laptopcomputer"
        case "Clothing": return "tshirt"
        case "Bag": return "bag"
        case "Keys": return "key"
        case "ID/Cards": return "person.text.rectangle"
        default: return "questionmark.circle"
        }
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground)))
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardBackground()) }
}
