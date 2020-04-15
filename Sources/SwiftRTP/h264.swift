//
//  File.swift
//  
//
//  Created by David Nadoba on 10.04.20.
//

import Foundation
import BinaryKit

public struct NALUnitType: Hashable {
    /// Resverd 0
    public static let reserved0 = Self(rawValue: 0)
    /// Coded slice of a non-IDR (instantaneous decoding refresh) picture
    public static let nonInstantaneousDecodingRefreshCodedSlice = Self(rawValue: 1)
    /// Coded slice data partition A
    public static let codedSliceDataPartitionA = Self(rawValue: 2)
    /// Coded slice data partition B
    public static let codedSliceDataPartitionB = Self(rawValue: 3)
    /// Coded slice data partition C
    public static let codedSliceDataPartitionC = Self(rawValue: 4)
    /// Instantaneous Decoding Refresh (IDR) Coded Slice
    public static let instantaneousDecodingRefreshCodedSlice = Self(rawValue: 5)
    /// Supplemental enhancement information (SEI)
    public static let supplementalEnhancementInformation  = Self(rawValue: 6)
    /// Sequence parameter set (SPS)
    public static let sequenceParameterSet = Self(rawValue: 7)
    /// Picture parameter set (PPS)
    public static let pictureParameterSet = Self(rawValue: 8)
    /// Access Unit Delmiter
    public static let accessUnitDelmiter = Self(rawValue: 9)
    /// End of sequence
    public static let endOfSequence = Self(rawValue: 10)
    /// End of stream
    public static let endOfStream = Self(rawValue: 11)
    /// Filler data
    public static let fillerData = Self(rawValue: 12)
    /// Sequence parameter set extension
    public static let sequenceParameterSetExtension = Self(rawValue: 13)
    /// Prefix Network Abstraction Layer (NAL) Unit
    public static let prefixNetworkAbstractionLayerUnit = Self(rawValue: 14)
    /// Subset sequence parameter set
    public static let subsetSequenceParameterSet = Self(rawValue: 15)
    /// Reserved 16
    public static let reserved16 = Self(rawValue: 16)
    /// Reserved 17
    public static let reserved17 = Self(rawValue: 17)
    /// Reserved 18
    public static let reserved18 = Self(rawValue: 18)
    /// Coded slice of an auxiliary coded picture without partitioning
    public static let codedSliceOfAnAuxiliaryCodedPictureWithoutPartitioning = Self(rawValue: 19)
    /// Coded slice extension
    public static let codedSliceExtension = Self(rawValue: 20)
    /// Coded slice extension for depth view components
    public static let codedSliceExtensionForDepthViewComponents = Self(rawValue: 21)
    /// Reserved 22
    public static let reserved22 = Self(rawValue: 22)
    /// Reserved 23
    public static let reserved23 = Self(rawValue: 23)
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
    /// Reserved 30
    public static let reserved30 = Self(rawValue: 30)
    /// Reserved 31
    public static let reserved31 = Self(rawValue: 31)
    
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        assert(rawValue & 0b0001_1111 == rawValue, "\(Self.self) is only allowed to use the first 5 bit's of rawValue.")
        self.rawValue = rawValue & 0b0001_1111
    }
}

extension NALUnitType: CustomStringConvertible {
    public var description: String {
        return "\(rawValue) - \(name)"
    }
    public var name: String {
        switch self {
        case .reserved0: return "Reserved 0"
        case .nonInstantaneousDecodingRefreshCodedSlice: return "Coded slice of a non-IDR (instantaneous decoding refresh) picture"
        case .codedSliceDataPartitionA: return "Coded slice data partition A"
        case .codedSliceDataPartitionB: return "Coded slice data partition B"
        case .codedSliceDataPartitionC: return "Coded slice data partition C"
        case .instantaneousDecodingRefreshCodedSlice: return "Instantaneous Decoding Refresh (IDR) Coded Slice"
        case .supplementalEnhancementInformation : return "Supplemental enhancement information (SEI)"
        case .sequenceParameterSet: return "Sequence parameter set (SPS)"
        case .pictureParameterSet: return "Picture parameter set (PPS)"
        case .accessUnitDelmiter: return "Access Unit Delmiter"
        case .endOfSequence: return "End of sequence"
        case .endOfStream: return "End of stream"
        case .fillerData: return "Filler data"
        case .sequenceParameterSetExtension: return "Sequence parameter set extension"
        case .prefixNetworkAbstractionLayerUnit: return "Prefix Network Abstraction Layer (NAL) Unit"
        case .subsetSequenceParameterSet: return "Subset sequence parameter set"
        case .reserved16: return "Reserved 16"
        case .reserved17: return "Reserved 17"
        case .reserved18: return "Reserved 18"
        case .codedSliceOfAnAuxiliaryCodedPictureWithoutPartitioning: return "Coded slice of an auxiliary coded picture without partitioning"
        case .codedSliceExtension: return "Coded slice extension"
        case .codedSliceExtensionForDepthViewComponents: return "Coded slice extension for depth view components"
        case .reserved22: return "Reserved 22"
        case .reserved23: return "Reserved 23"
        case .singleTimeAggregationPacketA: return "Single-Time Aggregation Packet type A (STAP-A)"
        case .singleTimeAggregationPacketB: return "Single-Time Aggregation Packet type B (STAP-B)"
        case .multiTimeAggregationPacket16: return "Multi-Time Aggregation Packet with 16-bit timestamp offset (MTAP16)"
        case .multiTimeAggregationPacket24: return "Multi-Time Aggregation Packet with 24-bit timestamp offset (MTAP24)"
        case .fragmentationUnitA: return "Fragmentation Unit type A (FU-A)"
        case .fragmentationUnitB: return "Fragmentation Unit type B (FU-B)"
        case .reserved30: return "Reserved 30"
        case .reserved31: return "Reserved 31"
        default: return "Unknown"
        }
    }
}

public extension NALUnitType {
    var isVideoCodingLayer: Bool { (1...5).contains(rawValue) }
    var isNonVideoCodingLayer: Bool { !isVideoCodingLayer }
    var isSinglePacket: Bool { (1...23).contains(rawValue) }
    var isReserved: Bool {
        [.reserved0,
         .reserved16, .reserved17, .reserved18,
         .reserved22, .reserved23,
         .reserved30, .reserved31,
        ].contains(self)
    }
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
    case didRecieveUnsuportedPackageType(NALUnitType)
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

public struct NALNonInterleavedPackageParser<D: MutableDataProtocol> where D.Index == Int {
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
            throw Error.didRecieveUnsuportedPackageType(header.type)
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
