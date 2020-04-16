import XCTest
@testable import BinaryKit
@testable import SwiftRTP

final class RTPHeaderTests: XCTestCase {
    func testReadAndWriteHeaderFromAndToBinaryData() throws {
        // Real-Time Transport Protocol
        // [Stream setup by HEUR RTP (frame 15721)]
        // 10.. .... = Version: RFC 1889 Version (2)
        // ..0. .... = Padding: False
        // ...0 .... = Extension: False
        // .... 0000 = Contributing source identifiers count: 0
        // 0... .... = Marker: False
        // Payload type: DynamicRTP-Type-96 (96)
        // Sequence number: 56880
        // [Extended sequence number: 122416]
        // Timestamp: 2579564480
        // Synchronization Source identifier: 0x991f69ce (2568972750)
        var reader = try XCTUnwrap(BinaryReader(hexString: "8060de3099c107c0991f69ce"))
        
        let header = try XCTUnwrap(try RTPHeader(from: &reader))
        XCTAssertEqual(header.version, .v2)
        XCTAssertEqual(header.padding, false)
        XCTAssertEqual(header.extension, false)
        XCTAssertEqual(header.marker, false)
        XCTAssertEqual(header.payloadType, 96)
        XCTAssertEqual(header.sequenceNumber, 56880)
        XCTAssertEqual(header.timestamp, 2579564480)
        XCTAssertEqual(header.synchronisationSource, 2568972750)
        XCTAssertEqual(header.contributingSourceCount, 0)
        XCTAssertEqual(header.contributingSources, nil)
        
        var bin = BinaryWriter()
        
        try header.write(to: &bin)
        
        XCTAssertEqual(bin.bytesStore,
            [0b10_0_0_0000, 0b0_1100000] +
            // |  | | |       | |
            // |  | | |       | Payload Type
            // |  | | |       Maker
            // |  | | Contribution source count
            // |  | Extension
            // |  Padding
            // Version
            UInt16(56880).toNetworkByteOrder.data +
            UInt32(2579564480).toNetworkByteOrder.data +
            UInt32(2568972750).toNetworkByteOrder.data
        )
    }
    
    func testReadAndWriteFromStruct() throws {
        let header = RTPHeader(version: .v2, padding: false, extension: false, marker: true, payloadType: 10, sequenceNumber: 1234, timestamp: 4321, synchronisationSource: 10, contributingSources: [9, 5])
        var writer = BinaryWriter()
        try header.write(to: &writer)
        var reader = BinaryReader(bytes: writer.bytesStore)
        XCTAssertEqual(header, try RTPHeader(from: &reader))
    }

    static var allTests = [
        ("testReadAndWriteHeaderFromAndToBinaryData", testReadAndWriteHeaderFromAndToBinaryData),
        ("testReadAndWriteFromStruct", testReadAndWriteFromStruct),
    ]
}
