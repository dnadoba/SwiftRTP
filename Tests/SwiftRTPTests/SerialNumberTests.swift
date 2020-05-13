//
//  File.swift
//  
//
//  Created by David Nadoba on 14.05.20.
//

import XCTest
import SwiftRTP

final class SerialNumberTests: XCTestCase {
    func testAddition() {
        XCTAssertEqual(255 as SerialNumber<UInt8> + 1, 0)
        XCTAssertEqual(100 as SerialNumber<UInt8> + 100, 200)
        XCTAssertEqual(200 as SerialNumber<UInt8> + 100, 44)
    }
    func testComparision() {
        XCTAssertTrue(1 as SerialNumber<UInt8> > 0)
        XCTAssertTrue(44 as SerialNumber<UInt8> > 0)
        XCTAssertTrue(100 as SerialNumber<UInt8> > 0)
        XCTAssertTrue(100 as SerialNumber<UInt8> > 0)
        XCTAssertTrue(100 as SerialNumber<UInt8> > 44)
        XCTAssertTrue(200 as SerialNumber<UInt8> > 100)
        XCTAssertTrue(255 as SerialNumber<UInt8> > 200)
        XCTAssertTrue(0 as SerialNumber<UInt8> > 255)
        XCTAssertTrue(100 as SerialNumber<UInt8> > 255)
        XCTAssertTrue(0 as SerialNumber<UInt8> > 200)
        XCTAssertTrue(44 as SerialNumber<UInt8> > 200)
        
        XCTAssertFalse(1 as SerialNumber<UInt8> < 0)
        XCTAssertFalse(44 as SerialNumber<UInt8> < 0)
        XCTAssertFalse(100 as SerialNumber<UInt8> < 0)
        XCTAssertFalse(100 as SerialNumber<UInt8> < 0)
        XCTAssertFalse(100 as SerialNumber<UInt8> < 44)
        XCTAssertFalse(200 as SerialNumber<UInt8> < 100)
        XCTAssertFalse(255 as SerialNumber<UInt8> < 200)
        XCTAssertFalse(0 as SerialNumber<UInt8> < 255)
        XCTAssertFalse(100 as SerialNumber<UInt8> < 255)
        XCTAssertFalse(0 as SerialNumber<UInt8> < 200)
        XCTAssertFalse(44 as SerialNumber<UInt8> < 200)

        XCTAssertFalse(200 as SerialNumber<UInt8> > 200)
        XCTAssertFalse(200 as SerialNumber<UInt8> < 200)
    }
}
