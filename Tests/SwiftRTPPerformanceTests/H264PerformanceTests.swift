import XCTest
import BinaryKit
import SwiftRTP

func generateRandomBytes<D: MutableDataProtocol>(size: Int, type: D.Type = D.self) -> D where D.Index == Int {
    let stride = MemoryLayout<Int>.stride
    let intCount = size/stride
    var d = D.init(repeating: 0, count: size)
    d.withContiguousMutableStorageIfAvailable { data in
        data.baseAddress!.withMemoryRebound(to: Int.self, capacity: intCount) { data2 in
            let intBuffer = UnsafeMutableBufferPointer(start: data2, count: intCount)
            for i in intBuffer.indices {
                intBuffer[i] = i
            }
        }
    }
    return d
}

func getTypicialInitalNalus<D: MutableDataProtocol>(
    idrSize: Int = 300 * 1000, // 300 kb
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
    func testH264AndRTPserialzePerfomanceUsingUInt8ContiguousArray() throws {
        typealias DataType = ContiguousArray<UInt8>
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
    func testH264SerialzePerfomanceUsingUInt8ContiguousArray() throws {
        typealias DataType = ContiguousArray<UInt8>
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
}
