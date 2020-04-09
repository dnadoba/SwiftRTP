import XCTest
@testable import SwiftRTP

final class SwiftRTPTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftRTP().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
