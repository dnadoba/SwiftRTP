//
//  File.swift
//  
//
//  Created by David Nadoba on 07.05.20.
//

import Foundation

public protocol ConcatableData: DataProtocol {
    mutating func concat(_ other: Self)
    mutating func concat(_ other: SubSequence)
}

extension DispatchData: ConcatableData {
    @inlinable
    public mutating func concat(_ other: Self) { append(other) }
    @inlinable
    public mutating func concat(_ other: SubSequence) {
        self.append(DispatchData(slice: other))
    }
}
extension DispatchData {
    @inlinable
    init(slice: Slice<Self>) {
//        let data = slice.withContiguousStorageIfAvailable { buffer in
//            DispatchData(bytesNoCopy: UnsafeRawBufferPointer(buffer), deallocator: .custom(nil, { [slice] in
//                _ = slice
//            }))
//        }
//        self = data ?? slice.base.subdata(in: slice.startIndex..<slice.endIndex)
        self = slice.base.subdata(in: slice.startIndex..<slice.endIndex)
    }
}

extension Data: ConcatableData {
    @inlinable
    public mutating func concat(_ other: Self) { append(other) }
}
extension Array: ConcatableData where Element == UInt8 {
    @inlinable
    public mutating func concat(_ other: Self) { append(contentsOf: other) }
    @inlinable
    public mutating func concat(_ other: SubSequence) { append(contentsOf: other) }
}

public protocol ReferenceInitalizeableData {
    init(referenceOrCopy: UnsafeRawBufferPointer, deallocator: @escaping () -> ())
    init(copyBytes: UnsafeRawBufferPointer)
}

extension ReferenceInitalizeableData {
    @inlinable
    public init(referenceOrCopy: Slice<UnsafeRawBufferPointer>, deallocator: @escaping () -> ()) {
        self.init(referenceOrCopy: UnsafeRawBufferPointer(rebasing: referenceOrCopy), deallocator: deallocator)
    }
}

extension ReferenceInitalizeableData {
    @inlinable
    public init(referenceOrCopy: UnsafeBufferPointer<UInt8>, deallocator: @escaping () -> ()) {
        self.init(referenceOrCopy: UnsafeRawBufferPointer(referenceOrCopy), deallocator: deallocator)
    }
    @inlinable
    public init(referenceOrCopy: Slice<UnsafeBufferPointer<UInt8>>, deallocator: @escaping () -> ()) {
        self.init(referenceOrCopy: UnsafeBufferPointer<UInt8>(rebasing: referenceOrCopy), deallocator: deallocator)
    }
}

extension DispatchData: ReferenceInitalizeableData {
    @inlinable
    public init(referenceOrCopy: UnsafeRawBufferPointer, deallocator: @escaping () -> ()) {
        self.init(bytesNoCopy: referenceOrCopy, deallocator: .custom(nil, deallocator))
    }
    @inlinable
    public init(copyBytes: UnsafeRawBufferPointer) {
        self.init(bytes: copyBytes)
    }
}
extension Data: ReferenceInitalizeableData {
    @inlinable
    public init(referenceOrCopy: UnsafeRawBufferPointer, deallocator: @escaping () -> ()) {
        guard let pointer = referenceOrCopy.baseAddress else {
            self.init()
            deallocator()
            return
        }
        self.init(bytes: pointer, count: referenceOrCopy.count)
        deallocator()
    }
    @inlinable
    public init(copyBytes: UnsafeRawBufferPointer) {
        self.init(buffer: copyBytes.bindMemory(to: UInt8.self))
    }
}

extension Array: ReferenceInitalizeableData where Element == UInt8 {
    @inlinable
    public init(referenceOrCopy: UnsafeRawBufferPointer, deallocator: @escaping () -> ()) {
        self.init(referenceOrCopy)
        deallocator()
    }
    @inlinable
    public init(copyBytes: UnsafeRawBufferPointer) {
        self.init(copyBytes.bindMemory(to: UInt8.self))
    }
}
