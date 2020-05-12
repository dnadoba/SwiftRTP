//
//  File.swift
//  
//
//  Created by David Nadoba on 10.04.20.
//

import Foundation
import BinaryKit


/// Namespace for all H.264/AVC related types
public enum H264 {}

extension H264 {
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
        
        /// - Parameter rawValue: allowed value range is from 0 to 31 inclusive (only the first 5 bits)
        @inlinable
        public init(rawValue: UInt8) {
            assert(rawValue & 0b0001_1111 == rawValue, "\(Self.self) is only allowed to use the first 5 bit's of rawValue.")
            self.rawValue = rawValue & 0b0001_1111
        }
    }
}

extension H264.NALUnitType: CaseIterable {
    public static var allCases: [Self] { (0...31).map(H264.NALUnitType.init(rawValue:)) }
}

/// Network Abstraction Layer (NAL) unit payload type
extension H264.NALUnitType: CustomStringConvertible {
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

public extension H264.NALUnitType {
    @inlinable var isVideoCodingLayer: Bool { (1...5).contains(rawValue) }
    @inlinable var isNonVideoCodingLayer: Bool { !isVideoCodingLayer }
    @inlinable var isSinglePacket: Bool { (1...23).contains(rawValue) }
    @inlinable var isReserved: Bool {
        [.reserved0,
         .reserved16, .reserved17, .reserved18,
         .reserved22, .reserved23,
         .reserved30, .reserved31,
        ].contains(self)
    }
}

extension H264 {
    /// Network Abstraction Layer Unit (NALU) Header
    public struct NALUnitHeader: Hashable {
        /// size in bytes if written to the network
        static let size: Int = 1
        /// The H.264 specification declares a value of 1 as a syntax violation.
        public var forbiddenZeroBit: Bool = false
        /// A value of 0 indicates that the content of the NAL
        /// unit is not used to reconstruct reference pictures for inter
        /// picture prediction.  Such NAL units can be discarded without
        /// risking the integrity of the reference pictures.  Values greater
        /// than 0 indicate that the decoding of the NAL unit is required to
        /// maintain the integrity of the reference pictures.
        /// - Note: Value range is from 0 to 2 inclusive (only the first 2 bits)
        public var referenceIndex: UInt8
        /// Network Abstraction Layer (NAL) unit payload type
        public var type: H264.NALUnitType
        @inlinable
        public init(forbiddenZeroBit: Bool = false, referenceIndex: UInt8, type: H264.NALUnitType) {
            self.forbiddenZeroBit = forbiddenZeroBit
            self.referenceIndex = referenceIndex
            self.type = type
        }
    }
}

extension H264.NALUnitHeader {
    @inlinable
    public init<D>(from reader: inout BinaryReader<D>) throws where D: DataProtocol {
        forbiddenZeroBit = try reader.readBool()
        referenceIndex = try reader.readBits(2)
        type = H264.NALUnitType(rawValue: try reader.readBits(5))
    }
}

extension H264.NALUnitHeader {
    @inlinable
    public func write<D>(to writer: inout BinaryWriter<D>) throws where D: DataProtocol {
        writer.writeBool(forbiddenZeroBit)
        writer.writeBits(from: referenceIndex, count: 2)
        writer.writeBits(from: type.rawValue, count: 5)
    }
    @inlinable
    public var byte: UInt8 {
        var writer = BinaryWriter()
        try! self.write(to: &writer)
        return writer.bytes[0]
    }
}

extension H264.NALUnitHeader {
    /// size in bytes if written to the network
    @inlinable
    public var size: Int { 1 }
}
extension H264 {
    public struct NALUnit<D>  {
        public var header: H264.NALUnitHeader
        public var payload: D
        @inlinable
        public init(header: H264.NALUnitHeader, payload: D) {
            self.header = header
            self.payload = payload
        }
    }
}

extension H264.NALUnit where D: DataProtocol {
    @inlinable
    public func write<D>(to writer: inout BinaryWriter<D>) throws where D: DataProtocol, D.Index == Int {
        try header.write(to: &writer)
        writer.writeBytes(payload)
    }
}

extension H264.NALUnit where D: MutableDataProtocol {
    @inlinable
    public var bytes: D {
        var mutableData = D([header.byte])
        mutableData.append(contentsOf: payload)
        return mutableData
    }
}

extension H264.NALUnit where D: DataProtocol {
    /// size in bytes if written to the network
    @inlinable
    public var size: Int { header.size + payload.count }
}

extension H264.NALUnit: Equatable where D: Equatable {}
extension H264.NALUnit: Hashable where D: Hashable {}
extension H264 {
    public struct FragmentationUnitHeader: Hashable {
        /// `isStart` indicates the start of a fragmented NAL unit.  When the following FU payload is not the start of a fragmented NAL unit payload, `isStart` is set to false.
        public var isStart: Bool
        /// When set to ture, `isEnd` indicates the end of a fragmented NAL unit, i.e., the last byte of the payload is also the last byte of the fragmented NAL unit. When the following FU payload is not the last fragment of a fragmented NAL unit, `isEnd` is set to false.
        public var isEnd: Bool
        /// The Reserved bit MUST be equal to 0 and MUST be ignored by the receiver.
        public var reservedBit: Bool = false
        public var type: H264.NALUnitType
        @inlinable
        public init(isStart: Bool, isEnd: Bool, reservedBit: Bool = false, type: H264.NALUnitType) {
            self.isStart = isStart
            self.isEnd = isEnd
            self.reservedBit = reservedBit
            self.type = type
        }
    }
}

extension H264.FragmentationUnitHeader {
    @inlinable
    public init<D>(from reader: inout BinaryReader<D>) throws where D: DataProtocol {
        isStart = try reader.readBool()
        isEnd = try reader.readBool()
        reservedBit = try reader.readBool()
        type = H264.NALUnitType(rawValue: try reader.readBits(5))
    }
}

extension H264.FragmentationUnitHeader {
    @inlinable
    public func write<D>(to writer: inout BinaryWriter<D>) throws where D: DataProtocol {
        writer.writeBool(isStart)
        writer.writeBool(isEnd)
        writer.writeBool(reservedBit)
        writer.writeBits(from: type.rawValue, count: 5)
    }
    @inlinable
    public var byte: UInt8 {
        var writer = BinaryWriter()
        try! self.write(to: &writer)
        return writer.bytes[0]
    }
}

extension H264.FragmentationUnitHeader {
    /// size in bytes if written to the network
    @inlinable
    public var size: Int { 1 }
}
extension H264 {
    public struct FragmentationUnitTypeAParser<D: MutableDataProtocol> where D.Index == Int {
        public enum Error: Swift.Error {
            case startAndEndBitIsSetInTheSamePackage
            case recivedFragmentBeforeStartFragment
            case recivedFragmentWithDifferentHeader
            case recivedFragmentEndBeforeStartFragment
        }
        @usableFromInline
        internal var fragmentHeader: H264.NALUnitHeader?
        @usableFromInline
        internal var fragmentPayload: D.SubSequence?
        @inlinable
        public mutating func readPackage(from reader: inout BinaryReader<D>, header: H264.NALUnitHeader) throws -> [H264.NALUnit<D.SubSequence>] {
            let unitHeader = try FragmentationUnitHeader(from: &reader)
            guard unitHeader.isStart != true || unitHeader.isEnd != true else {
                throw Error.startAndEndBitIsSetInTheSamePackage
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
                    throw Error.recivedFragmentBeforeStartFragment
                }
                fragmentPayload?.append(contentsOf: payload)
            }
            guard fragmentHeader == naluHeader else {
                throw Error.recivedFragmentWithDifferentHeader
            }
            if unitHeader.isEnd {
                defer {
                    fragmentHeader = nil
                    fragmentPayload = nil
                }
                guard let header = fragmentHeader, let payload = fragmentPayload else {
                    throw Error.recivedFragmentEndBeforeStartFragment
                }
                return [H264.NALUnit(header: header, payload: payload)]
            } else {
                return []
            }
        }
    }
}

struct While: Sequence {
    var `while`: () -> Bool
    @usableFromInline
    func makeIterator() -> AnyIterator<Void> {
        .init {
            self.`while`() ? () : nil
        }
    }
    @usableFromInline
    init(_ while: @escaping () -> Bool) {
        self.`while` = `while`
    }
}

extension H264 {
    public struct NALNonInterleavedPacketParser<D: MutableDataProtocol> where D.Index == Int {
        public enum Error: Swift.Error {
            case singleTimeAggreationPackageA_sizOfChildNALUToSmall
            case didRecieveUnsuportedPacketType(H264.NALUnitType)
        }
        @usableFromInline
        internal var fragmentationUnitTypeAParser = FragmentationUnitTypeAParser<D>()
        public init() {}
        @inlinable
        public mutating func readPackage(from reader: inout BinaryReader<D>) throws -> [H264.NALUnit<D.SubSequence>] {
            let header = try H264.NALUnitHeader(from: &reader)
            if header.type.isSinglePacket {
                return [H264.NALUnit(header: header, payload: try reader.readRemainingBytes())]
            }
            switch header.type {
            case .singleTimeAggregationPacketA:
                return try parseSingleTimeAggregationPacketTypeA(from: &reader)
            case .fragmentationUnitA:
                return try fragmentationUnitTypeAParser.readPackage(from: &reader, header: header)
            default:
                throw Error.didRecieveUnsuportedPacketType(header.type)
            }
        }
        @usableFromInline
        internal func parseSingleTimeAggregationPacketTypeA(from reader: inout BinaryReader<D>) throws -> [H264.NALUnit<D.SubSequence>] {
            var isEmpty = reader.isEmpty
            return try While({ !isEmpty }).map {
                defer { isEmpty = reader.isEmpty }
                let naluSize = try reader.readInteger(type: UInt16.self)
                guard naluSize >= 1 else { throw Error.singleTimeAggreationPackageA_sizOfChildNALUToSmall }
                let header = try H264.NALUnitHeader(from: &reader)
                let payloadSize = naluSize - 1
                return H264.NALUnit(header: header, payload: try reader.readBytes(Int(payloadSize)))
            }
        }
    }
}

extension RandomAccessCollection where Index == Int {
    /// Splits the given sequence up into slices that contain `maxLength` elements. The last slice can contain less than `maxLength` elements.
    /// - Parameter maxLength: number of items in one slice. Must be greater than 0.
    /// - Returns: Slices with `maxLength` elements each. The last slice can contain less than `maxLength` elements.
    /// - Precondition: sliceLength > 0
    @inlinable
    public func split(maxLength: Int) -> [SubSequence] {
        precondition(maxLength > 0, "`sliceLength` must be greater than 0")
        var slices = [SubSequence]()
        slices.reserveCapacity(count/maxLength)
        var remainingSubsequence = self[...]
        while !remainingSubsequence.isEmpty {
            let startIndex = remainingSubsequence.startIndex
            let endIndex = Swift.min(startIndex + maxLength, remainingSubsequence.endIndex)
            slices.append(self[startIndex..<endIndex])
            remainingSubsequence = remainingSubsequence[endIndex...]
        }
        return slices
    }
/// the current implementation of `split(maxLenght:)` is a workaround because.
/// `DispatchData.SubSequence.prefix(_:)` and `DispatchData.SubSequence.suffix(:_)` has awefull performance.
/// The following implementation is much nicer and does work with any Collection.
//
//    @inlinable
//    public func split(maxLength: Int) -> [SubSequence] {
//        precondition(maxLength > 0, "`sliceLength` must be greater than 0")
//        var slices = [SubSequence]()
//        slices.reserveCapacity(count/maxLength)
//        var remainingSubsequence = self[...]
//        while !remainingSubsequence.isEmpty {
//            slices.append(remainingSubsequence.prefix(maxLength))
//            remainingSubsequence = remainingSubsequence.dropFirst(maxLength)
//        }
//        return slices
//    }
}

extension RTPPayloadType {
    public static var h264 = Self(rawValue: 96)
}

@usableFromInline
func sizeOfSingleTimeAggregationPacketA(naluSizeSum: Int, naluCount: Int) -> Int {
    // each NALU in a SingleTimeAggregationPacketA is prefixed with the size as an UInt16 of the next NALU.
    let naluPrefixSize = naluCount * 2
    return H264.NALUnitHeader.size + naluSizeSum + naluPrefixSize
}

@usableFromInline
let sizeOfFragmentationUnitIndicatorAndHeader = 2

public protocol Writable {
    var size: Int { get }
    func write<D>(to writer: inout BinaryWriter<D>) throws where D: MutableDataProtocol, D.Index == Int
}

extension Writable {
    @inlinable
    public func bytes<D>(type: D.Type = D.self) throws -> D where D: MutableDataProtocol, D.Index == Int {
        var writer = BinaryWriter<D>(capacity: size)
        try write(to: &writer)
        return writer.bytes
    }
}

extension Writable {
    public func toAnyWriteable<D: MutableDataProtocol>() -> AnyWriteable<D> where D.Index == Int {
        .init(size: self.size) { writer in
            try self.write(to: &writer)
        }
    }
}

public struct AnyWriteable<D: MutableDataProtocol> where D.Index == Int  {
    public typealias Handler = (inout BinaryWriter<D>) throws -> ()
    public var size: Int
    @usableFromInline
    internal var writeHandler: Handler
    @inlinable
    public init(size: Int, _ writeHandler: @escaping Handler) {
        self.size = size
        self.writeHandler = writeHandler
    }
    @inlinable
    public func write(to writer: inout BinaryWriter<D>) throws {
        try writeHandler(&writer)
    }
    @inlinable
    public func bytes() throws -> D {
        var writer = BinaryWriter<D>(capacity: size)
        try writeHandler(&writer)
        return writer.bytes
    }
}

extension AnyWriteable: Equatable where D: Equatable {
    @inlinable
    public static func == (lhs: AnyWriteable<D>, rhs: AnyWriteable<D>) -> Bool {
        (try? lhs.bytes()) == (try? rhs.bytes())
    }
}

extension AnyWriteable: ExpressibleByArrayLiteral where D == [UInt8] {
    @inlinable
    public init(arrayLiteral elements: UInt8...) {
        self.init(size: elements.count) { (writer) in
            writer.writeBytes(elements)
        }
    }
}

extension H264.FragmentationUnitHeader: Writable {}
extension H264.NALUnitHeader: Writable {}
extension RTPHeader: Writable {}


extension ReferenceInitalizeableData {
    @inlinable
    public init<D: ContiguousBytes>(copyBytes: D) {
        self = copyBytes.withUnsafeBytes { buffer in
            Self(copyBytes: buffer)
        }
    }
}

extension H264 {
    public struct NALNonInterleavedPacketSerializer<HeaderD: MutableDataProtocol & ContiguousBytes, D> where HeaderD.Index == Int, D: ReferenceInitalizeableData, D: ConcatableData, D.Index == Int {
        public typealias TemporaryDataType = [UInt8]
        public var maxSizeOfNaluPacket: Int
        @usableFromInline
        internal var maxSizeOfNaluInSingleTimeAggregationPacketA: Int { maxSizeOfNaluPacket - sizeOfSingleTimeAggregationPacketA(naluSizeSum: 0, naluCount: 1) }
        public var payloadType: RTPPayloadType = .h264
        public enum Error: Swift.Error {
        }
        @inlinable
        public init(maxSizeOfNalu: Int) {
            self.maxSizeOfNaluPacket = maxSizeOfNalu
        }
        @inlinable
        public func serialize(_ nalus: [NALUnit<D>], timestamp: UInt32, lastNALUsForGivenTimestamp: Bool) throws -> [RTPPacket<HeaderD, D>] {
            var packets = [RTPPacket<HeaderD, D>]()
            var aggregatedNalus = [NALUnit<D>]()
            // This is the sum of all nalus currently aggregated. this does not include the cost of the SingleTimeAggregationPacketA metadata(e.g. header and NALU prefix size)
            var aggregatedNaluSize: Int { aggregatedNalus.map(\.size).reduce(0, +) }
            for (index, nalu) in nalus.enumerated() {
                let isLast = index == nalus.index(before: nalus.endIndex)
                
                // size is to big to fit into a single packet
                if nalu.size > maxSizeOfNaluPacket {
                    if !aggregatedNalus.isEmpty {
                        packets.append(try serializeAsSignelOrAggregatedPacket(aggregatedNalus, timestamp: timestamp, lastNALUsForGivenTimestamp: false))
                        aggregatedNalus.removeAll()
                    }
                    packets.append(contentsOf: try serializeAsFragmentationUnitTypeA(nalu, timestamp: timestamp, isLastNALUForGivenTimestamp: lastNALUsForGivenTimestamp && isLast))
                    
                // size is not to big to fit into a single packet but to big to fit into an aggregated packet
                } else if nalu.size > maxSizeOfNaluInSingleTimeAggregationPacketA {
                    if aggregatedNalus.count > 0 {
                        packets.append(try serializeAsSignelOrAggregatedPacket(aggregatedNalus, timestamp: timestamp, lastNALUsForGivenTimestamp: false))
                        aggregatedNalus.removeAll()
                    }
                    packets.append(try serializeAsSinglePacket(nalu, timestamp: timestamp, isLastNALUForGivenTimestamp: lastNALUsForGivenTimestamp && isLast))

                } else {
                    let newAggregatedSizeIncludingPackagingMetadata = sizeOfSingleTimeAggregationPacketA(
                        naluSizeSum: aggregatedNaluSize + nalu.size,
                        naluCount: aggregatedNalus.count + 1
                    )
                    if newAggregatedSizeIncludingPackagingMetadata > maxSizeOfNaluPacket {
                        if aggregatedNalus.count > 0 {
                            packets.append(try serializeAsSignelOrAggregatedPacket(aggregatedNalus, timestamp: timestamp, lastNALUsForGivenTimestamp: false))
                            aggregatedNalus.removeAll()
                        }
                    }
                    aggregatedNalus.append(nalu)
                }
            }
            if !aggregatedNalus.isEmpty {
                packets.append(try serializeAsSignelOrAggregatedPacket(aggregatedNalus, timestamp: timestamp, lastNALUsForGivenTimestamp: lastNALUsForGivenTimestamp))
            }
            return packets
        }
        @inlinable
        @inline(__always)
        public func serializeAsSignelOrAggregatedPacket(_ nalus: [NALUnit<D>], timestamp: UInt32, lastNALUsForGivenTimestamp: Bool) throws -> RTPPacket<HeaderD, D> {
            assert(nalus.count != 0, "can not send zero nalus as single packet or \(NALUnitType.singleTimeAggregationPacketA)")
            if nalus.count == 1, let nalu = nalus.first {
                return try serializeAsSinglePacket(nalu, timestamp: timestamp, isLastNALUForGivenTimestamp: lastNALUsForGivenTimestamp)
            }
            return try serializeAsSingleTimeAggregationPacketTypeA(nalus, timestamp: timestamp, lastNALUsForGivenTimestamp: lastNALUsForGivenTimestamp)
        }
        @inlinable
        @inline(__always)
        public func serializeAsSinglePacket(_ nalu: NALUnit<D>, timestamp: UInt32, isLastNALUForGivenTimestamp: Bool) throws -> RTPPacket<HeaderD, D> {
            assert(nalu.size <= maxSizeOfNaluPacket)
            let header = try nalu.header.bytes(type: TemporaryDataType.self)
            var data = D(copyBytes: header)
            data.concat(nalu.payload)
            return RTPPacket(payloadType: payloadType, payload: data, timestamp: timestamp, marker: isLastNALUForGivenTimestamp)
        }
        @inlinable
        @inline(__always)
        public func serializeAsSingleTimeAggregationPacketTypeA(_ nalus: [NALUnit<D>], timestamp: UInt32, lastNALUsForGivenTimestamp: Bool) throws -> RTPPacket<HeaderD, D> {
            assert(nalus.count != 0, "can not send zero NALUs as \(NALUnitType.singleTimeAggregationPacketA)")
            assert(nalus.count != 1, "should not send single NALU as \(NALUnitType.singleTimeAggregationPacketA)")
            
            let header = NALUnitHeader(referenceIndex: nalus.map(\.header.referenceIndex).max() ?? 0, type: .singleTimeAggregationPacketA)
            let payloadSizes = nalus.map(\.size).reduce(0, +)
            let size = sizeOfSingleTimeAggregationPacketA(naluSizeSum: payloadSizes, naluCount: nalus.count)
            assert(size <= maxSizeOfNaluPacket)
            
            
            var data = D(copyBytes: try header.bytes(type: TemporaryDataType.self))
            for nalu in nalus {
                var writer = BinaryWriter<TemporaryDataType>(capacity: nalu.header.size + MemoryLayout<UInt16>.size)
                writer.writeInt(UInt16(nalu.size))
                try nalu.header.write(to: &writer)
                data.concat(D.init(copyBytes: writer.bytes))
                data.concat(nalu.payload)
            }
            
            return RTPPacket(payloadType: payloadType, payload: data, timestamp: timestamp, marker: lastNALUsForGivenTimestamp)
        }
        @inlinable
        @inline(__always)
        public func serializeAsFragmentationUnitTypeA(_ nalu: NALUnit<D>, timestamp: UInt32, isLastNALUForGivenTimestamp: Bool) throws -> [RTPPacket<HeaderD, D>] {
            assert(nalu.size > maxSizeOfNaluPacket, "can not send NALU as Fragmentation Unit Type A because size(\(nalu.size)) of NALU is smaller than maxSizeOfNalu(\(maxSizeOfNaluPacket))")
            let nalus = nalu.payload.split(maxLength: maxSizeOfNaluPacket - sizeOfFragmentationUnitIndicatorAndHeader)
            return nalus.enumerated().map { index, payload in
                let isFirstFragment = index == nalus.startIndex
                let isLastFragment = index == nalus.index(before: nalus.endIndex)
                let fragmentationIndicator = H264.NALUnitHeader(
                    forbiddenZeroBit: nalu.header.forbiddenZeroBit,
                    referenceIndex: nalu.header.referenceIndex,
                    type: .fragmentationUnitA)
                
                let fragmentationHeader = FragmentationUnitHeader(isStart: isFirstFragment, isEnd: isLastFragment, type: nalu.header.type)
                
                let header = AnyWriteable<HeaderD>(size: fragmentationIndicator.size + fragmentationHeader.size) { writer in
                    try fragmentationIndicator.write(to: &writer)
                    try fragmentationHeader.write(to: &writer)
                    if !D.canConcatDataWithoutReallocation {
                        writer.writeBytes(payload)
                    }
                }
                
                
                
                return RTPPacket(payloadType: payloadType, header: header, payload: D.canConcatDataWithoutReallocation ? D(payload) : nil, timestamp: timestamp, marker: isLastFragment && isLastNALUForGivenTimestamp)
            }
        }
    }
}

