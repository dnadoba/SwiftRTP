//
//  SerialNumberWithOverflowCount.swift
//  
//
//  Created by David Nadoba on 15.07.20.
//

public struct SerialNumberWithOverflowCount<
    Number: UnsignedInteger & FixedWidthInteger,
    OverflowNumber: FixedWidthInteger & UnsignedInteger
>: Hashable {
    public var serialNumber: SerialNumber<Number>
    public var overflowCount: OverflowNumber
    
    public init(serialNumber: SerialNumber<Number>, overflowCount: OverflowNumber = 0) {
        self.serialNumber = serialNumber
        self.overflowCount = overflowCount
    }
    public init(number: Number = 0, overflowCount: OverflowNumber = 0) {
        self.serialNumber = SerialNumber(rawValue: number)
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
    public func incremented(by other: SerialNumber<Number>) -> Self {
        var copy = self
        copy.increment(by: other)
        return copy
    }
}

extension SerialNumberWithOverflowCount {
    @inlinable
    public func sum<SumType: UnsignedInteger & FixedWidthInteger>(sumType: SumType.Type = SumType.self) -> SumType {
        SumType(serialNumber.rawValue) + SumType(overflowCount) << SumType(OverflowNumber.bitWidth)
    }
}
