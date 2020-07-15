//
//  SerialNumber.swift
//  
//
//  Created by David Nadoba on 13.05.20.
//


/// Implementation of Serial Number Arithmetic as defined in `RFC 1982` https://tools.ietf.org/html/rfc1982
public struct SerialNumber<Number: UnsignedInteger & FixedWidthInteger>: RawRepresentable {
    public var rawValue: Number
    public init(rawValue: Number) {
        self.rawValue = rawValue
    }
}

extension SerialNumber: Hashable where Number: Hashable {}

extension SerialNumber: Encodable where Number: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension SerialNumber: Decodable where Number: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(Number.self))
    }
}

extension SerialNumber: ExpressibleByIntegerLiteral where Number: _ExpressibleByBuiltinIntegerLiteral{
    public init(integerLiteral value: Number) {
        self.init(rawValue: value)
    }
}

extension SerialNumber {
    /// Addition as defined in `RFC 1982`: `(lhs + rhs) modulo (2^Number.bitWidth)`.
    /// Addition of a value greater than or equal to `2^(Number.bitWidth - 1)` is undefined.
    public static func +(lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue &+ rhs.rawValue)
    }
    /// Addition as defined in `RFC 1982`: `(lhs + rhs) modulo (2^Number.bitWidth)` with overflow reporting.
    /// Addition of a value greater than or equal to `2^(Number.bitWidth - 1)` is undefined.
    public func addingReportingOverflow(_ rhs: Self) -> (number: Self, overflow: Bool) {
        let (value, overflow) = self.rawValue.addingReportingOverflow(rhs.rawValue)
        return (Self(rawValue: value), overflow)
    }
}


extension SerialNumber: Comparable {
    /// Comparision as defined in `RFC 1982`.
    public static func <(lhs: Self, rhs: Self) -> Bool {
        let i1 = lhs.rawValue
        let i2 = rhs.rawValue
        let halfMaxValue = 1 << (Number.bitWidth - 1)
        guard i1 != i2 else { return false }
        return (i1 < i2 && i2 - i1 < halfMaxValue) ||
            (i1 > i2 && i1 - i2 > halfMaxValue)
    }
}
