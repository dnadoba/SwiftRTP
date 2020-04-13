//
//  File.swift
//  
//
//  Created by David Nadoba on 10.04.20.
//

import Foundation
import BinaryKit

public struct NALUnitType: Hashable {
    public static let reserved0 = Self(rawValue: 0)
    
    /// sequence parameter set (SPS)
    public static let sequenceParameterSet = Self(rawValue: 7)
    /// picture parameter set (PPS)
    public static let pictureParameterSet = Self(rawValue: 8)
    
    /// Single-Time Aggregation Packet type A (STAP-A)
    public static let singleTimeAggregationPacketA = Self(rawValue: 24)
    /// Single-Time Aggregation Packet type B (STAP-B)
    public static let singleTimeAggregationPacketB = Self(rawValue: 25)
    /// Multi-Time Aggregation Packet with 16-bit timestamp offset (MTAP16)
    public static let multiTimeAggregationPacket16 = Self(rawValue: 26)
    /// Multi-Time Aggregation Packet with 24-bit timestamp offset (MTAP24)
    public static let multiTimeAggregationPacket24 = Self(rawValue: 27)
    
    /// Fragmentation Unit type A (FU-A)
    public static let fragmentationUnitA = Self(rawValue: 28)
    /// Fragmentation Unit type B (FU-B)
    public static let fragmentationUnitB = Self(rawValue: 29)
    
    public static let reserved30 = Self(rawValue: 30)
    public static let reserved31 = Self(rawValue: 31)
    
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        assert(rawValue & 0b0001_1111 == rawValue, "\(Self.self) is only allowed to use the first 5 bit's of rawValue.")
        self.rawValue = rawValue & 0b0001_1111
    }
}

public extension NALUnitType {
    var isSinglePacket: Bool { (1...23).contains(rawValue) }
}

public struct NALUnitHeader: Hashable {
    public var forbiddenZeroBit: Bool
    public var referenceIndex: UInt8
    public var type: NALUnitType
}

extension NALUnitHeader {
    public init<D>(reader: inout BinaryReader<D>) throws where D: DataProtocol {
        forbiddenZeroBit = try reader.readBool()
        referenceIndex = try reader.readBits(2)
        type = NALUnitType(rawValue: try reader.readBits(5))
    }
}

extension NALUnitHeader {
    public func write<D>(to writer: inout BinaryWriter<D>) throws where D: DataProtocol {
        writer.writeBool(forbiddenZeroBit)
        writer.writeBits(from: referenceIndex, count: 2)
        writer.writeBits(from: type.rawValue, count: 5)
    }
    public var byte: UInt8 {
        var writer = BinaryWriter()
        try! self.write(to: &writer)
        return writer.bytesStore[0]
    }
}

public struct NALUnit<D: DataProtocol> where D.Index == Int {
    public var header: NALUnitHeader
    public var payload: D
}

extension NALUnit where D: MutableDataProtocol {
    public var bytes: D {
        var mutableData = D([header.byte])
        mutableData.append(contentsOf: payload)
        return mutableData
    }
}

extension NALUnit: Equatable where D: Equatable {}
extension NALUnit: Hashable where D: Hashable {}

public enum NALPackageParserError: Error {
    case singleTimeAggreationPackageA_sizOfChildNALUToSmall
    case fragmentationUnitA_startAndEndBitIsSetInTheSamePackage
    case fragmentationUnitA_recivedFragmentBeforeStartFragment
    case fragmentationUnitA_recivedFragmentWithDifferentHeader
    case fragmentationUnitA_recivedFragmentEndBeforeStartFragment
}

struct WhileSequence: Sequence {
    var `while`: () -> Bool
    func makeIterator() -> AnyIterator<Void> {
        return AnyIterator({
            if self.`while`() {
                return ()
            } else {
                return nil
            }
        })
    }
    init(_ while: @escaping () -> Bool) {
        self.`while` = `while`
    }
}

public struct NALPackageParser<D: MutableDataProtocol> where D.Index == Int {
    private typealias Error = NALPackageParserError
    private var fragmentHeader: NALUnitHeader?
    private var fragmentPayload: D.SubSequence?
    public init() {}
    public mutating func readPackage(from reader: inout BinaryReader<D>) throws -> [NALUnit<D.SubSequence>] {
        let header = try NALUnitHeader(reader: &reader)
        if header.type.isSinglePacket {
            return [NALUnit(header: header, payload: try reader.readRemainingBytes())]
        }
        switch header.type {
        case .singleTimeAggregationPacketA:
            var isEmpty = reader.isEmpty
            return try WhileSequence({ !isEmpty }).map {
                defer { isEmpty = reader.isEmpty }
                let naluSize = try reader.readInteger(type: UInt16.self)
                guard naluSize >= 1 else { throw Error.singleTimeAggreationPackageA_sizOfChildNALUToSmall }
                let header = try NALUnitHeader(reader: &reader)
                let payloadSize = naluSize - 1
                return NALUnit(header: header, payload: try reader.readBytes(Int(payloadSize)))
            }
        case .fragmentationUnitA:
            let unitHeader = try FragmentationUnitHeader(reader: &reader)
            guard unitHeader.isStart != true || unitHeader.isEnd != true else {
                throw Error.fragmentationUnitA_startAndEndBitIsSetInTheSamePackage
            }
            var naluHeader = header
            naluHeader.type = unitHeader.type
            let payload = try reader.readRemainingBytes()
            if unitHeader.isStart {
                if fragmentHeader != nil {
                    print("did recive new start fragment before finish last fragment")
                }
                fragmentHeader = naluHeader
                fragmentPayload = payload
            } else {
                guard fragmentPayload != nil else {
                    throw Error.fragmentationUnitA_recivedFragmentBeforeStartFragment
                }
                fragmentPayload?.append(contentsOf: payload)
            }
            guard fragmentHeader == naluHeader else {
                throw Error.fragmentationUnitA_recivedFragmentWithDifferentHeader
            }
            if unitHeader.isEnd {
                defer {
                    fragmentHeader = nil
                    fragmentPayload = nil
                }
                guard let header = fragmentHeader, let payload = fragmentPayload else {
                    throw Error.fragmentationUnitA_recivedFragmentEndBeforeStartFragment
                }
                return [NALUnit(header: header, payload: payload)]
            } else {
                return []
            }
        default:
            print("did recieve unssported packet of type \(header.type)")
            return []
        }
    }
}

struct FragmentationUnitHeader: Hashable {
    /// `isStart` indicates the start of a fragmented NAL unit.  When the following FU payload is not the start of a fragmented NAL unit payload, `isStart` is set to false.
    var isStart: Bool
    /// When set to ture, `isEnd` indicates the end of a fragmented NAL unit, i.e., the last byte of the payload is also the last byte of the fragmented NAL unit. When the following FU payload is not the last fragment of a fragmented NAL unit, `isEnd` is set to false.
    var isEnd: Bool
    /// The Reserved bit MUST be equal to 0 and MUST be ignored by the receiver.
    var reservedBit: Bool = false
    var type: NALUnitType
}

extension FragmentationUnitHeader {
    public init<D>(reader: inout BinaryReader<D>) throws where D: DataProtocol {
        isStart = try reader.readBool()
        isEnd = try reader.readBool()
        reservedBit = try reader.readBool()
        type = NALUnitType(rawValue: try reader.readBits(5))
    }
}

extension FragmentationUnitHeader {
    public func write<D>(to writer: inout BinaryWriter<D>) throws where D: DataProtocol {
        writer.writeBool(isStart)
        writer.writeBool(isEnd)
        writer.writeBool(reservedBit)
        writer.writeBits(from: type.rawValue, count: 5)
    }
}
