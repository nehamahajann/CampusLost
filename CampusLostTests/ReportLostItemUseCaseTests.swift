//
//  ReportLostItemUseCaseTests.swift
//  CampusLost
//
//  Created by Neha on 3/10/2026.
//


import XCTest
@testable import CampusLost

final class ReportLostItemUseCaseTests: XCTestCase {
    var repository: MockLostFoundRepository!

    override func setUp() {
        repository = MockLostFoundRepository()
    }

    func test_reportLostItem_succeeds_withValidDetails() throws {
        try ReportLostItemUseCase(repository: repository).execute(
            itemName: "AirPods", category: "Electronics",
            itemDescription: "White case with a small scratch on the lid",
            location: "Building 11", date: .now
        )
        XCTAssertEqual(repository.lostReports.count, 1)
        XCTAssertEqual(repository.lostReports.first?.itemName, "AirPods")
    }

    func test_reportLostItem_fails_whenItemNameIsEmpty() {
        XCTAssertThrowsError(try ReportLostItemUseCase(repository: repository).execute(
            itemName: "   ", category: "Electronics",
            itemDescription: "White case with a small scratch on the lid",
            location: "Building 11", date: .now
        )) { error in
            XCTAssertEqual(error as? LostItemReportingError, .emptyItemName)
        }
    }

    func test_reportLostItem_fails_whenDateIsInTheFuture() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        XCTAssertThrowsError(try ReportLostItemUseCase(repository: repository).execute(
            itemName: "AirPods", category: "Electronics",
            itemDescription: "White case with a small scratch on the lid",
            location: "Building 11", date: tomorrow
        )) { error in
            XCTAssertEqual(error as? LostItemReportingError, .futureLostDate)
        }
    }
}
