//
//  SwiftRTCP.swift
//  
//
//  Created by David Nadoba on 14.07.20.
//

import Foundation

public struct RTCPPacketType: RawRepresentable {
    public static let senderReport = RTCPPacketType(rawValue: 200)
    public static let recieverReport = RTCPPacketType(rawValue: 201)
    public static let sourceDescription = RTCPPacketType(rawValue: 202)
    public static let goodbye = RTCPPacketType(rawValue: 203)
    public static let applicationDefined = RTCPPacketType(rawValue: 204)
    
    
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

public struct RTCPSourceDescriptionType: RawRepresentable {
    public static let endOfSourceDescriptionList = RTCPSourceDescriptionType(rawValue: 0)
    public static let canonicalName = RTCPSourceDescriptionType(rawValue: 1)
    public static let userName = RTCPSourceDescriptionType(rawValue: 2)
    public static let userEmailAddress = RTCPSourceDescriptionType(rawValue: 3)
    public static let userPhoneNumber = RTCPSourceDescriptionType(rawValue: 4)
    public static let geographicUserLocation = RTCPSourceDescriptionType(rawValue: 5)
    public static let nameOfApplicationOrTool = RTCPSourceDescriptionType(rawValue: 6)
    public static let noticeAboutTheSource = RTCPSourceDescriptionType(rawValue: 7)
    public static let privateExtension = RTCPSourceDescriptionType(rawValue: 8)
    
    
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

public struct RTCPHeader {
    /// This field identifies the version of RTP
    public var version: RTPVersion
    
    /// If the padding bit is set, this individual RTCP packet contains some additional padding octets at the end which are not part of the control information but are included in the length field. The last octet of the padding is a count of how many padding octets should be ignored, including itself (it will be a multiple of four). Padding may be needed by some encryption algorithms with fixed block sizes. In a compound RTCP packet, padding is only required on one individual packet because the compound packet is encrypted as a whole for the method in Section 9.1. Thus, padding must only be added to the last individual packet, and if padding is added to that packet, the padding bit must be set only on that packet. This convention aids the header validity checks described in Appendix A.2 and allows detection of packets from some early implementations that incorrectly set the padding bit on the first individual packet and add padding to the last individual packet.
    public var padding: Bool
    public var packetType: RTCPPacketType
    /// The synchronization source identifier for the originator of this packet.
    public var synchronizationSource: RTPSynchronizationSource
}

public struct NTPTimestamp {
    var seconds: UInt32
    var faction: UInt32
}

public struct RTCPSenderReportInfo {
    public var ntpTimestamp: NTPTimestamp
    public var rtpTimestamp: UInt32
    /// sender's packet count
    public var packetCount: UInt32
    /// sender's octet count
    public var byteCount: UInt32
}

public struct RTCPReportBlock {
    public var packetLostFraction: UInt8
    public var packetLostCount: UInt32 // UInt24
    public var highestRecievedSequenceNumber: SerialNumberWithOverflowCount<UInt16, UInt16>
    public var interarrivalJitter: UInt32
    /// The middle 32 bits out of 64 in the NTP timestamp (as explained in Section 4) received as part of the most recent RTCP sender report (SR) packet from source SSRC n. If no SR has been received yet, the field is set to zero.
    public var lastSenderReportMiddleOfNTPTimestamp: UInt32
    /// The delay, expressed in units of 1/65536 seconds, between receiving the last SR packet from source SSRC n and sending this reception report block. If no SR packet has been received yet from SSRC n, the DLSR field is set to zero.
    public var delaySinceLastSenderReport: UInt32
}

public struct RTCPSenderReport {
    public var info: RTCPSenderReportInfo
    public var blocks: [RTCPReportBlock]
}

public struct RTCPRecieverReport {
    public var blocks: [RTCPReportBlock]
}


public struct RTCPSourceDescription {
    
}
