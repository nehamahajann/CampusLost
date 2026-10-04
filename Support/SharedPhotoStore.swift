//
//  SharedPhotoStore.swift
//  CampusLost
//
//  Created by Neha on 3/10/2026.
//


import UIKit

/// Reads the photo a user shared into CampusLost via the Share Extension,
/// from the same App Group container the extension wrote it into.
enum SharedPhotoStore {
    private static let appGroupID = "group.Neha.CampusLost"

    static func pendingPhoto() -> UIImage? {
        guard UserDefaults(suiteName: appGroupID)?.bool(forKey: "hasPendingSharedPhoto") == true,
              let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        else { return nil }

        let fileURL = containerURL.appendingPathComponent("pending_found_photo.jpg")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    static func clearPendingPhoto() {
        UserDefaults(suiteName: appGroupID)?.set(false, forKey: "hasPendingSharedPhoto")
    }
}
