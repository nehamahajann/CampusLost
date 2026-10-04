import Vision
import UIKit

/// Uses Apple's on-device Vision framework to suggest a category for a
/// found item's photo — entirely offline, no API keys or network calls,
/// unlike a cloud-based image recognition service.
enum PhotoClassificationService {
    /// Maps Vision's general-purpose classification labels onto
    /// CampusLost's own domain categories.
    private static let categoryKeywords: [String: String] = [
        "electronics": "Electronics", "headphone": "Electronics", "phone": "Electronics",
        "laptop": "Electronics", "computer": "Electronics", "camera": "Electronics",
        "earbud": "Electronics", "charger": "Electronics", "cable": "Electronics",

        "clothing": "Clothing", "jacket": "Clothing", "shirt": "Clothing",
        "sweater": "Clothing", "hoodie": "Clothing", "hat": "Clothing", "scarf": "Clothing",

        "bag": "Bag", "backpack": "Bag", "handbag": "Bag", "luggage": "Bag",

        "key": "Keys",

        "card": "ID/Cards", "wallet": "ID/Cards", "document": "ID/Cards",
    ]

    static func suggestCategory(for image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: nil)
                    return
                }

                // Check the top few confident labels against our keyword map.
                let topLabels = results
                    .filter { $0.confidence > 0.2 }
                    .prefix(5)
                    .map { $0.identifier.lowercased() }

                for label in topLabels {
                    for (keyword, category) in categoryKeywords {
                        if label.contains(keyword) {
                            continuation.resume(returning: category)
                            return
                        }
                    }
                }
                continuation.resume(returning: nil)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage)
            try? handler.perform([request])
        }
    }
}
