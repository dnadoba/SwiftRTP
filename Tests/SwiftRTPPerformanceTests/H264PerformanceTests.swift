import XCTest
import BinaryKit
import SwiftRTP

func generateRandomBytes<D: MutableDataProtocol>(size: Int, type: D.Type = D.self) -> D where D.Index == Int {
    return D((0..<size).map({ _ in UInt8.random(in: UInt8.min..<UInt8.max)}))
}
func getTypicialInitalNalus<D: MutableDataProtocol>(
    idrSize: Int = 30 * 1000 * 1000, // 30 kb
    type: D.Type = D.self
) -> [H264.NALUnit<D>] where D.Index == Int {
    let pps = H264.NALUnit(
        header: .init(referenceIndex: 2, type: .pictureParameterSet),
        payload: generateRandomBytes(size: 3, type: type))
    let sps = H264.NALUnit(
        header: .init(referenceIndex: 2, type: .sequenceParameterSet),
        payload: generateRandomBytes(size: 20, type: type))
    let idr = H264.NALUnit(
        header: .init(referenceIndex: 1, type: .instantaneousDecodingRefreshCodedSlice),
        payload: generateRandomBytes(size: idrSize, type: type))
    return [pps, sps, idr]
}

final class H264PerformanceTests: XCTestCase {
    
    func testSerialzePerfomanceUsingDataType() throws {
        typealias DataType = Data
        var rtpSerialzer = RTPSerialzer(maxSizeOfPacket: 1500, synchronisationSource: RTPSynchronizationSource(rawValue: 1))
        let h264Serialzer = H264.NALNonInterleavedPacketSerializer<DataType>(maxSizeOfNalu: rtpSerialzer.maxSizeOfPayload)
        
        let nalus = getTypicialInitalNalus(type: DataType.self)
        measure {
            do {
                let packets = try h264Serialzer.serialize(nalus, timestamp: 2, lastNALUsForGivenTimestamp: true)
                for packet in packets {
                    _ = try rtpSerialzer.serialze(packet, dataType: DataType.self)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    func testSerialzePerfomanceUsingArrayType() throws {
        typealias DataType = Array<UInt8>
        var rtpSerialzer = RTPSerialzer(maxSizeOfPacket: 1500, synchronisationSource: RTPSynchronizationSource(rawValue: 1))
        let h264Serialzer = H264.NALNonInterleavedPacketSerializer<DataType>(maxSizeOfNalu: rtpSerialzer.maxSizeOfPayload)
        
        let nalus = getTypicialInitalNalus(type: DataType.self)
        measure {
            do {
                let packets = try h264Serialzer.serialize(nalus, timestamp: 2, lastNALUsForGivenTimestamp: true)
                for packet in packets {
                    _ = try rtpSerialzer.serialze(packet, dataType: DataType.self)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
