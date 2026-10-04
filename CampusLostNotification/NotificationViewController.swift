//
//  NotificationViewController.swift
//  CampusLostNotification
//
//  Created by Neha on 3/10/2026.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import SwiftUI

final class NotificationViewController: UIViewController, UNNotificationContentExtension {

    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        let lostItemName = userInfo["lostItemName"] as? String ?? "Your item"
        let foundLocation = userInfo["foundLocation"] as? String ?? "campus"

        let hosting = UIHostingController(rootView: MatchNotificationView(
            lostItemName: lostItemName,
            foundLocation: foundLocation
        ))
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hosting.didMove(toParent: self)
        preferredContentSize = CGSize(width: view.bounds.width, height: 140)
    }
}

/// The rich custom view shown instead of the default notification banner,
/// when a potential match is found for something a student reported lost.
struct MatchNotificationView: View {
    let lostItemName: String
    let foundLocation: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 4) {
                Text("Possible match found!")
                    .font(.headline)
                Text("\(lostItemName) — reported found near \(foundLocation)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Open CampusLost to review")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            Spacer()
        }
        .padding()
    }
}
