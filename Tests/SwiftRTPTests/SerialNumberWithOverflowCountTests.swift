//
//  File.swift
//  
//
//  Created by David Nadoba on 27.07.20.
//

import XCTest
import SwiftRTP

final class SerialNumberWithOverflowCountTests: XCTestCase {
    func testIncrement() {
        XCTAssertEqual(
            SerialNumberWithOverflowCount<UInt8, UInt8>(serialNumber: 255).incremented(by: 1),
            SerialNumberWithOverflowCount(serialNumber: 0, overflowCount: 1)
        )
        XCTAssertEqual(
            SerialNumberWithOverflowCount<UInt8, UInt8>(serialNumber: 100).incremented(by: 100),
            SerialNumberWithOverflowCount(serialNumber: 200, overflowCount: 0)
        )
        XCTAssertEqual(
            SerialNumberWithOverflowCount<UInt8, UInt8>(serialNumber: 200).incremented(by: 100),
            SerialNumberWithOverflowCount(serialNumber: 44, overflowCount: 1)
        )
    }
    
    func test() {
        XCTAssertEqual(
            SerialNumberWithOverflowCount<UInt8, UInt8>(serialNumber: 0).sum(sumType: UInt16.self),
            0
        )
        XCTAssertEqual(
            SerialNumberWithOverflowCount<UInt8, UInt8>(serialNumber: 255).incremented(by: 200).sum(sumType: UInt16.self),
            255 + 200
        )
        XCTAssertEqual(
            SerialNumberWithOverflowCount<UInt8, UInt8>(serialNumber: 255).incremented(by: 255).incremented(by: 250).sum(sumType: UInt16.self),
            255 + 255 + 250
        )
    }
}
