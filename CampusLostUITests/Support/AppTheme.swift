//
//  AppTheme.swift
//  CampusLost
//
//  Created by Neha on 3/10/2026.
//
import SwiftUI

/// Centralised design tokens for CampusLost, so every screen shares one
/// consistent visual language instead of plain default styling.
enum AppTheme {
    static let accent = Color(red: 0.25, green: 0.45, blue: 0.85)   // trustworthy blue
    static let lost = Color(red: 0.88, green: 0.45, blue: 0.20)      // warm amber — searching
    static let found = Color(red: 0.25, green: 0.65, blue: 0.45)    // green — resolved
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
