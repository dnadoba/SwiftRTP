import XCTest
import BinaryKit
import SwiftRTP

func generateRandomBytes<D: ReferenceInitalizeableData>(size: Int, type: D.Type = D.self) -> D {
    let stride = MemoryLayout<Int>.stride
    var d = Array<UInt8>(repeating: 0, count: size)
    d.withUnsafeMutableBytes { data in
        let intBuffer = data.bindMemory(to: Int.self)
        for i in intBuffer.indices {
            intBuffer[i] = i
        }
    }
    return D.init(copyBytes: d)
}

func getTypicialInitalNalus<D: ReferenceInitalizeableData>(
    idrSize: Int = 3000 * 1000, // 3000 kb
    type: D.Type = D.self
) -> [H264.NALUnit<D>] {
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
    let maxDatagramSize = 1500
    // MARK: - H264 and RTP Serialze Perfomance
    func testH264AndRTPserialzePerfomanceUsingData() throws {
        typealias DataType = Data
        var rtpSerialzer = RTPSerialzer(maxSizeOfPacket: maxDatagramSize, synchronisationSource: RTPSynchronizationSource(rawValue: 1))
        let h264Serialzer = H264.NALNonInterleavedPacketSerializer<DataType>(maxSizeOfNalu: rtpSerialzer.maxSizeOfPayload)
        
        let nalus = getTypicialInitalNalus(type: DataType.self)
        measure {
            do {
                let packets = try h264Serialzer.serialize(nalus, timestamp: 2, lastNALUsForGivenTimestamp: true)
                for packet in packets {
                    _ = try rtpSerialzer.serialze(packet)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    func testH264AndRTPserialzePerfomanceUsingUInt8Array() throws {
        typealias DataType = Array<UInt8>
        var rtpSerialzer = RTPSerialzer(maxSizeOfPacket: maxDatagramSize, synchronisationSource: RTPSynchronizationSource(rawValue: 1))
        let h264Serialzer = H264.NALNonInterleavedPacketSerializer<DataType>(maxSizeOfNalu: rtpSerialzer.maxSizeOfPayload)
        
        let nalus = getTypicialInitalNalus(type: DataType.self)
        measure {
            do {
                let packets = try h264Serialzer.serialize(nalus, timestamp: 2, lastNALUsForGivenTimestamp: true)
                for packet in packets {
                    _ = try rtpSerialzer.serialze(packet)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    func testH264AndRTPserialzePerfomanceUsingDispatchData() throws {
        typealias DataType = DispatchData
        var rtpSerialzer = RTPSerialzer(maxSizeOfPacket: maxDatagramSize, synchronisationSource: RTPSynchronizationSource(rawValue: 1))
        let h264Serialzer = H264.NALNonInterleavedPacketSerializer<DataType>(maxSizeOfNalu: rtpSerialzer.maxSizeOfPayload)
        
        let nalus = getTypicialInitalNalus(type: DataType.self)
        measure {
            do {
                let packets = try h264Serialzer.serialize(nalus, timestamp: 2, lastNALUsForGivenTimestamp: true)
                for packet in packets {
                    _ = try rtpSerialzer.serialze(packet)
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    // MARK: - H264 Serialze Perfomance
    func testH264SerialzePerfomanceUsingData() throws {
        typealias DataType = Data
        let rtpSerialzer = RTPSerialzer(maxSizeOfPacket: maxDatagramSize, synchronisationSource: RTPSynchronizationSource(rawValue: 1))
        let h264Serialzer = H264.NALNonInterleavedPacketSerializer<DataType>(maxSizeOfNalu: rtpSerialzer.maxSizeOfPayload)
        
        let nalus = getTypicialInitalNalus(type: DataType.self)
        measure {
            do {
                _ = try h264Serialzer.serialize(nalus, timestamp: 2, lastNALUsForGivenTimestamp: true)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    func testH264SerialzePerfomanceUsingUInt8Array() throws {
        typealias DataType = Array<UInt8>
        let rtpSerialzer = RTPSerialzer(maxSizeOfPacket: maxDatagramSize, synchronisationSource: RTPSynchronizationSource(rawValue: 1))
        let h264Serialzer = H264.NALNonInterleavedPacketSerializer<DataType>(maxSizeOfNalu: rtpSerialzer.maxSizeOfPayload)
        
        let nalus = getTypicialInitalNalus(type: DataType.self)
        measure {
            do {
                _ = try h264Serialzer.serialize(nalus, timestamp: 2, lastNALUsForGivenTimestamp: true)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    func testH264SerialzePerfomanceUsingDispatchData() throws {
        typealias DataType = DispatchData
        let rtpSerialzer = RTPSerialzer(maxSizeOfPacket: maxDatagramSize, synchronisationSource: RTPSynchronizationSource(rawValue: 1))
        let h264Serialzer = H264.NALNonInterleavedPacketSerializer<DataType>(maxSizeOfNalu: rtpSerialzer.maxSizeOfPayload)
        
        let nalus = getTypicialInitalNalus(type: DataType.self)
        measure {
            do {
                _ = try h264Serialzer.serialize(nalus, timestamp: 2, lastNALUsForGivenTimestamp: true)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
