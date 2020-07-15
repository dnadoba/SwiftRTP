//
//  SerialNumberWithOverflowCount.swift
//  
//
//  Created by David Nadoba on 15.07.20.
//

public struct SerialNumberWithOverflowCount<Number: UnsignedInteger & FixedWidthInteger, OverflowNumber: FixedWidthInteger> {
    public var serialNumber: SerialNumber<Number>
    public var overflowCount: OverflowNumber
    
    public init(serialNumber: SerialNumber<Number>, overflowCount: OverflowNumber) {
        self.serialNumber = serialNumber
        self.overflowCount = overflowCount
    }
    public init(serialNumber: Number = 0, overflowCount: OverflowNumber = 0) {
        self.serialNumber = SerialNumber(rawValue: serialNumber)
        self.overflowCount = overflowCount
    }
}

extension SerialNumberWithOverflowCount {
    @inlinable
    public mutating func increment(by other: SerialNumber<Number>) {
        let (newSerialNumber, didOverflow) = self.serialNumber.addingReportingOverflow(other)
        self.serialNumber = newSerialNumber
        if didOverflow {
            self.overflowCount += 1
        }
    }
    @inlinable
    public mutating func incremented(by other: SerialNumber<Number>) -> Self {
        var copy = self
        copy.increment(by: other)
        return copy
    }
}
