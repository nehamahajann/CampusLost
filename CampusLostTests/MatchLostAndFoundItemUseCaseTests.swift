//
//  MatchLostAndFoundItemUseCaseTests.swift
//  CampusLost
//
//  Created by Neha on 3/10/2026.
//


import XCTest
@testable import CampusLost

final class MatchLostAndFoundItemUseCaseTests: XCTestCase {
    var repository: MockLostFoundRepository!

    override func setUp() {
        repository = MockLostFoundRepository()
    }

    func test_matchLostAndFoundItem_succeeds_whenCategoryLocationAndDateAlign() throws {
        let today = Date.now
        let lost = LostReportItem(
            id: UUID(), itemName: "AirPods", category: "Electronics",
            itemDescription: "White case", location: "Building 11",
            date: today, status: "unmatched", createdAt: today
        )
        repository.foundReports.append(FoundReportItem(
            id: UUID(), itemName: "AirPods", category: "Electronics",
            itemDescription: "White case", location: "Building 11",
            date: today, status: "unmatched", createdAt: today
        ))

        let match = try MatchLostAndFoundItemUseCase(repository: repository).execute(for: lost)
        XCTAssertEqual(match.status, "pending_review")
        XCTAssertEqual(repository.matches.count, 1)
    }

    func test_matchLostAndFoundItem_fails_whenNoCandidatesExist() {
        let lost = LostReportItem(
            id: UUID(), itemName: "Umbrella", category: "Other",
            itemDescription: "Blue umbrella", location: "Library",
            date: .now, status: "unmatched", createdAt: .now
        )
        XCTAssertThrowsError(try MatchLostAndFoundItemUseCase(repository: repository).execute(for: lost)) { error in
            XCTAssertEqual(error as? ItemMatchingError, .noCandidatesFound)
        }
    }
}