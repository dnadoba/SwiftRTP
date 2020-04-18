import XCTest
@testable import BinaryKit
@testable import SwiftRTP

final class RTPSerialzerTests: XCTestCase {
    func testSequenceNumberGenerator() {
        var generator = RTPSequenceNumberGenerator(inital: UInt16.max - 2)
        XCTAssertEqual(generator.next(), UInt16.max - 2)
        XCTAssertEqual(generator.next(), UInt16.max - 1)
        XCTAssertEqual(generator.next(), UInt16.max)
        XCTAssertEqual(generator.next(), 0)
        XCTAssertEqual(generator.next(), 1)
        XCTAssertEqual(generator.next(), 2)
    }
    func testSerializer() throws {
        var serializer = RTPSerialzer<[UInt8]>.init(maxSizeOfPacket: 100, synchronisationSource: 1, initalSequenceNumber: 9)
        let packet = try serializer.serialze(RTPPacket(payloadType: 2, payload: [3, 4], timestamp: 6, marker: true))
        XCTAssertEqual(
            packet,
            try RTPHeader(
                marker: true,
                payloadType: 2,
                sequenceNumber: 9,
                timestamp: 6,
                synchronisationSource: 1
            ).asNetworkData() +
            [3, 4] // payload
        )
    }
}
