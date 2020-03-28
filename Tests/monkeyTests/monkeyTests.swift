import XCTest
@testable import monkey

final class monkeyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(monkey().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
