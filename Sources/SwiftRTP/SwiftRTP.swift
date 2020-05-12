import Foundation
import BinaryKit

public struct RTPVersion: RawRepresentable, Hashable {
    /// the protocol version of the initially implemented in the “vat” audio tool
    public static let v0 = RTPVersion(rawValue: 0)
    /// the firstdraft version of RTP
    public static let v1 = RTPVersion(rawValue: 1)
    /// current version
    public static let v2 = RTPVersion(rawValue: 2)
    
    public var rawValue: UInt8
    @inlinable
    public init(rawValue: UInt8) {
        assert(rawValue & 0b0000_0011 == rawValue, "\(Self.self) is only allowed to use the first 2 bit's of rawValue.")
        self.rawValue = rawValue & 0b0000_0011
    }
}

public struct RTPPayloadType: RawRepresentable, Hashable {
    public var rawValue: UInt8
    @inlinable
    public init(rawValue: UInt8) {
        assert(rawValue & 0b0111_1111 == rawValue, "\(Self.self) is only allowed to use the first 7 bit's of the rawValue.")
        self.rawValue = rawValue & 0b0111_1111
    }
}

/// Synchronization Source (SSRC) -
/// The source of a stream of RTP packets, identified by a 32-bit numeric SSRC identifier carried in the RTP header so as not to be dependent upon the network address. All packets from a synchronization source form part of the same timing and sequence number space, so a receiver groups packets by synchronization source for playback. Examples of synchronization sources include the sender of a stream of packets derived from a signal source such as a microphone or a camera, or an RTP mixer (see below). A synchronization source may change its data format, e.g., audio encoding, over time. The SSRC identifier is a randomly chosen value meant to be globally unique within a particular RTP session (see Section 8). A participant need not use the same SSRC identifier for all the RTP sessions in a multimedia session; the binding of the SSRC identifiers is provided through RTCP (see Section 6.5.1). If a participant generates multiple streams in one RTP session, for example from separate video cameras, each must be identified as a different SSRC.
public struct RTPSynchronizationSource: RawRepresentable, Hashable {
    public var rawValue: UInt32
    @inlinable
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

/// Contributing Source (CSRC) -
/// A source of a stream of RTP packets that has contributed to the combined stream produced by an RTP mixer (see below). The mixer inserts a list of the SSRC identifiers of the sources that contributed to the generation of a particular packet into the RTP header of that packet. This list is called the CSRC list. An example application is audio conferencing where a mixer indicates all the talkers whose speech was combined to produce the outgoing packet, allowing the receiver to indicate the current talker, even though all the audio packets contain the same SSRC identifier (that of the mixer).
public struct RTPContributingSource: RawRepresentable, Hashable {
    public var rawValue: UInt32
    @inlinable
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public struct RTPHeader: Equatable {
    /// This field identifies the version of RTP
    public var version: RTPVersion = .v2
    
    /// If the padding bit is set, the packet contains one or more additional padding octets at the end which are not part of the payload. The last octet of the padding contains a count of how many padding octets should be ignored, including itself. Padding may be needed by some encryption algorithms with fixed block sizes or for carrying several RTP packets in a lower-layer protocol data unit.
    public var padding: Bool = false
    
    /// If true, the fixed header must be followed by exactly one header extension, with a format defined in Section 5.3.1.
    public var `extension`: Bool = false
    
    /// The Contributing source (CSRC) count contains the number of CSRC identifiers that follow the fixed header.
    public var contributingSourceCount: Int { contributingSources?.count ?? 0 }
    
    /// The interpretation of the marker is defined by a profile. It is intended to allow significant events such as frame boundaries to be marked in the packet stream. A profile may define additional marker bits or specify that there is no marker bit by changing the number of bits in the payload type field (see Section 5.3).
    public var marker: Bool
    
    /// This field identifies the format of the RTP payload and determines its interpretation by the application. A profile may specify a default static mapping of payload type codes to payload formats. Additional payload type codes may be defined dynamically through non-RTP means (see Section 3). A set of default mappings for audio and video is specified in the companion RFC 3551 [1]. An RTP source may change the payload type during a session, but this field should not be used for multiplexing separate media streams (see Section 5.2).
    /// A receiver must ignore packets with payload types that it does not understand.
    public var payloadType: RTPPayloadType
    
    /// The sequence number increments by one for each RTP data packet sent, and may be used by the receiver to detect packet loss and to restore packet sequence. The initial value of the sequence number should be random (unpredictable) to make known-plaintext attacks on encryption more difficult, even if the source itself does not encrypt according to the method in Section 9.1, because the packets may flow through a translator that does. Techniques for choosing unpredictable numbers are discussed in [17].
    public var sequenceNumber: UInt16
    
    /// The timestamp reflects the sampling instant of the first octet in the RTP data packet. The sampling instant must be derived from a clock that increments monotonically and linearly in time to allow synchronization and jitter calculations (see Section 6.4.1). The resolution of the clock must be sufficient for the desired synchronization accuracy and for measuring packet arrival jitter (one tick per video frame is typically not sufficient). The clock frequency is dependent on the format of data carried as payload and is specified statically in the profile or payload format specification that defines the format, or may be specified dynamically for payload formats defined through non-RTP means. If RTP packets are generated periodically, the nominal sampling instant as determined from the sampling clock is to be used, not a reading of the system clock. As an example, for fixed-rate audio the timestamp clock would likely increment by one for each sampling period. If an audio application reads blocks covering 160 sampling periods from the input device, the timestamp would be increased by 160 for each such block, regardless of whether the block is transmitted in a packet or dropped as silent.
    /// The initial value of the timestamp should be random, as for the sequence number. Several consecutive RTP packets will have equal timestamps if they are (logically) generated at once, e.g., belong to the same video frame. Consecutive RTP packets may contain timestamps that are not monotonic if the data is not transmitted in the order it was sampled, as in the case of MPEG interpolated video frames. (The sequence numbers of the packets as transmitted will still be monotonic.)
    /// RTP timestamps from different media streams may advance at different rates and usually have independent, random offsets. Therefore, although these timestamps are sufficient to reconstruct the timing of a single stream, directly comparing RTP timestamps from different media is not effective for synchronization. Instead, for each medium the RTP timestamp is related to the sampling instant by pairing it with a timestamp from a reference clock (wallclock) that represents the time when the data corresponding to the RTP timestamp was sampled. The reference clock is shared by all media to be synchronized. The timestamp pairs are not transmitted in every data packet, but at a lower rate in RTCP SR packets as described in Section 6.4.
    /// The sampling instant is chosen as the point of reference for the RTP timestamp because it is known to the transmitting endpoint and has a common definition for all media, independent of encoding delays or other processing. The purpose is to allow synchronized presentation of all media sampled at the same time.
    /// Applications transmitting stored data rather than data sampled in real time typically use a virtual presentation timeline derived from wallclock time to determine when the next frame or other unit of each medium in the stored data should be presented. In this case, the RTP timestamp would reflect the presentation time for each unit. That is, the RTP timestamp for each unit would be related to the wallclock time at which the unit becomes current on the virtual presentation timeline. Actual presentation occurs some time later as determined by the receiver.
    /// An example describing live audio narration of prerecorded video illustrates the significance of choosing the sampling instant as the reference point. In this scenario, the video would be presented locally for the narrator to view and would be simultaneously transmitted using RTP. The “sampling instant” of a video frame transmitted in RTP would be established by referencing its timestamp to the wallclock time when that video frame was presented to the narrator. The sampling instant for the audio RTP packets containing the narrator’s speech would be established by referencing the same wallclock time when the audio was sampled. The audio and video may even be transmitted by different hosts if the reference clocks on the two hosts are synchronized by some means such as NTP. A receiver can then synchronize presentation of the audio and video packets by relating their RTP timestamps using the timestamp pairs in RTCP SR packets.
    public var timestamp: UInt32
    
    /// The SSRC field identifies the synchronization source. This identifier should be chosen randomly, with the intent that no two synchronization sources within the same RTP session will have the same SSRC identifier. An example algorithm for generating a random identifier is presented in Appendix A.6. Although the probability of multiple sources choosing the same identifier is low, all RTP implementations must be prepared to detect and resolve collisions. Section 8 describes the probability of collision along with a mechanism for resolving collisions and detecting RTP-level forwarding loops based on the uniqueness of the SSRC identifier. If a source changes its source transport address, it must also choose a new SSRC identifier to avoid being interpreted as a looped source (see Section 8.2).
    public var synchronisationSource: RTPSynchronizationSource
    
    /// The CSRC list identifies the contributing sources for the payload contained in this packet. The number of identifiers is given by the CC field. If there are more than 15 contributing sources, only 15 can be identified. CSRC identifiers are inserted by mixers (see Section 7.1), using the SSRC identifiers of contributing sources. For example, for audio packets the SSRC identifiers of all sources that were mixed together to create a packet are listed, allowing correct talker indication at the receiver.
    /// - Note: 0 to 15 items
    public var contributingSources: [RTPContributingSource]?
    
    @inlinable
    public init(
        version: RTPVersion = .v2,
        padding: Bool = false,
        extension: Bool = false,
        marker: Bool,
        payloadType: RTPPayloadType,
        sequenceNumber: UInt16,
        timestamp: UInt32,
        synchronisationSource: RTPSynchronizationSource,
        contributingSources: [RTPContributingSource]? = nil
    ) {
        self.version = version
        self.padding = padding
        self.extension = `extension`
        self.marker = marker
        self.payloadType = payloadType
        self.sequenceNumber = sequenceNumber
        self.timestamp = timestamp
        self.synchronisationSource = synchronisationSource
        self.contributingSources = contributingSources
    }
}

extension RTPHeader {
    @inlinable
    public init<D>(from reader: inout BinaryReader<D>) throws where D: DataProtocol {
        self.version = RTPVersion(rawValue: try reader.readBits(2))
        self.padding = try reader.readBool()
        self.extension = try reader.readBool()
        let contributingSourceCount = try reader.readBits(4, type: Int.self)
        self.marker = try reader.readBool()
        self.payloadType = RTPPayloadType(rawValue: try reader.readBits(7))
        self.sequenceNumber = try reader.readInteger()
        self.timestamp = try reader.readInteger()
        self.synchronisationSource = RTPSynchronizationSource(rawValue: try reader.readInteger())
        if contributingSourceCount == 0 {
            self.contributingSources = nil
        } else {
            self.contributingSources = try (0..<contributingSourceCount).map { _ in
                RTPContributingSource(rawValue: try reader.readInteger())
            }
        }
    }
}

extension RTPHeader {
    @inlinable
    public func write<D>(to writer: inout BinaryWriter<D>) throws where D: DataProtocol {
        writer.writeBits(from: version.rawValue, count: 2)
        writer.writeBool(padding)
        writer.writeBool(`extension`)
        writer.writeBits(from: contributingSourceCount, count: 4)
        writer.writeBool(marker)
        writer.writeBits(from: payloadType.rawValue, count: 7)
        writer.writeInt(sequenceNumber)
        writer.writeInt(timestamp)
        writer.writeInt(synchronisationSource.rawValue)
        contributingSources?.forEach { contributingSource in
            writer.writeInt(contributingSource.rawValue)
        }
    }
    @inlinable
    public func asNetworkData<D>(type: D.Type = D.self) throws -> D where D: MutableDataProtocol, D.Index == Int {
        var writer = BinaryWriter<D>(capacity: size)
        try write(to: &writer)
        return writer.bytes
    }
}



extension RTPHeader {
    @inlinable
    public static func size(contributingSourceCount: Int) -> Int{
        12 + // fixed size of the header
        contributingSourceCount * 4 // size of the optional CSRC identifiers
    }
    /// size in bytes if written to the network
    @inlinable
    public var size: Int {
        Self.size(contributingSourceCount: contributingSourceCount)
    }
}


public struct RTPPacket<D: MutableDataProtocol, Payload: DataProtocol> where D.Index == Int {
    public var payloadType: RTPPayloadType
    public var timestamp: UInt32
    public var marker: Bool
    public var includesPadding: Bool = false
    public var includesHeaderExtension: Bool = false
    public var header: AnyWriteable<D>?
    public var payload: Payload?
    
    @inlinable
    public init(payloadType: RTPPayloadType, header: AnyWriteable<D>? = nil, payload: Payload? = nil, timestamp: UInt32, marker: Bool, includesPadding: Bool = false, includesHeaderExtension: Bool = false) {
        self.payloadType = payloadType
        self.timestamp = timestamp
        self.marker = marker
        self.includesPadding = includesPadding
        self.includesHeaderExtension = includesHeaderExtension
        self.header = header
        self.payload = payload
    }
    
}

extension RTPPacket: Equatable where D: Equatable, Payload: Equatable {
    private var headerAndPayload: D {
        var writer = BinaryWriter<D>(capacity: (header?.size ?? 0) + (payload?.count ?? 0))
        try? header?.write(to: &writer)
        if let payload = payload {
            writer.writeBytes(payload)
        }
        return writer.bytes
    }
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.payloadType == rhs.payloadType &&
            lhs.timestamp == rhs.timestamp &&
            lhs.marker == rhs.marker &&
            lhs.includesPadding == rhs.includesPadding &&
            lhs.includesHeaderExtension == rhs.includesHeaderExtension &&
            lhs.headerAndPayload == rhs.headerAndPayload
    }
}


public struct RTPSequenceNumberGenerator {
    @usableFromInline
    internal var sequenceNumber: UInt16
    @inlinable
    public init() {
        self.init(inital: .random(in: UInt16.min...UInt16.max))
    }
    @inlinable
    public init(inital sequenceNumber: UInt16) {
        self.sequenceNumber = sequenceNumber
    }
    @inlinable
    public mutating func next() -> UInt16 {
        defer { sequenceNumber &+= 1 }
        return sequenceNumber
    }
}

public struct RTPSerialzer{
    public typealias TemporaryDataType = [UInt8]
    public var maxSizeOfPacket: Int
    public var version: RTPVersion = .v2
    public var synchronisationSource: RTPSynchronizationSource
    public var contributingSources: [RTPContributingSource] = []
    @usableFromInline
    internal var sequenceNumberGenerator = RTPSequenceNumberGenerator()
    @inlinable
    public init(
        maxSizeOfPacket: Int,
        synchronisationSource: RTPSynchronizationSource,
        contributingSources: [RTPContributingSource] = [],
        version: RTPVersion = .v2,
        initalSequenceNumber: UInt16? = nil
    ) {
        self.maxSizeOfPacket = maxSizeOfPacket
        self.version = version
        self.synchronisationSource = synchronisationSource
        self.contributingSources = contributingSources
        self.sequenceNumberGenerator = initalSequenceNumber.map(RTPSequenceNumberGenerator.init(inital:)) ?? RTPSequenceNumberGenerator()
    }
    
    @inlinable
    public var maxSizeOfPayload: Int {
        maxSizeOfPacket - RTPHeader.size(contributingSourceCount: contributingSources.count)
    }
    @inlinable
    public mutating func serialze<D, Payload>(
        _ packet: RTPPacket<D, Payload>
    ) throws -> Payload where D: MutableDataProtocol, D: ContiguousBytes, D.Index == Int, Payload: ReferenceInitalizeableData, Payload: ConcatableData {
        let header = RTPHeader(
            version: version,
            padding: packet.includesPadding,
            extension: packet.includesHeaderExtension,
            marker: packet.marker,
            payloadType: packet.payloadType,
            sequenceNumber: sequenceNumberGenerator.next(),
            timestamp: packet.timestamp,
            synchronisationSource: synchronisationSource
        )
        var headerWriter = BinaryWriter<D>.init(capacity: header.size + (packet.header?.size ?? 0))
        try header.write(to: &headerWriter)
        try packet.header?.write(to: &headerWriter)
        
        
        if let payload = packet.payload {
            var data = Payload(copyBytes: headerWriter.bytes)
            data.concat(payload)
            return data
        } else {
            if D.self == Payload.self,
                let noCopyData = headerWriter.bytes as? Payload {
                return noCopyData
            } else { 
                return Payload(copyBytes: headerWriter.bytes)
            }
        }
    }
}
