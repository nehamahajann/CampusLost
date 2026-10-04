import XCTest
@testable import CampusLost

final class ReportFoundItemUseCaseTests: XCTestCase {
    var repository: MockLostFoundRepository!

    override func setUp() {
        repository = MockLostFoundRepository()
    }

    func test_reportFoundItem_succeeds_withValidDetails() throws {
        try ReportFoundItemUseCase(repository: repository).execute(
            itemName: "AirPods", category: "Electronics",
            itemDescription: "White case", location: "Building 11", date: .now
        )
        XCTAssertEqual(repository.foundReports.count, 1)
    }

    func test_reportFoundItem_fails_whenLocationIsMissing() {
        XCTAssertThrowsError(try ReportFoundItemUseCase(repository: repository).execute(
            itemName: "AirPods", category: "Electronics",
            itemDescription: "White case", location: "   ", date: .now
        )) { error in
            XCTAssertEqual(error as? FoundItemReportingError, .missingLocation)
        }
    }
}
