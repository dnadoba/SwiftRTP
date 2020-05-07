//
//  File.swift
//  
//
//  Created by David Nadoba on 07.05.20.
//

import Foundation

public protocol ConcatableData {
    mutating func concat(_ other: Self)
}

extension DispatchData: ConcatableData {
    @inlinable
    public mutating func concat(_ other: Self) { append(other) }
}
extension Data: ConcatableData {
    @inlinable
    public mutating func concat(_ other: Self) { append(other) }
}
extension Array: ConcatableData where Element == UInt8 {
    @inlinable
    public mutating func concat(_ other: Self) { append(contentsOf: other) }
}

public protocol ReferenceInitalizeableData {
    init(referenceOrCopy: UnsafeRawBufferPointer, deallocator: @escaping () -> ())
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
}
extension Data {
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
}

extension Array: ReferenceInitalizeableData where Element == UInt8 {
    @inlinable
    public init(referenceOrCopy: UnsafeRawBufferPointer, deallocator: @escaping () -> ()) {
        self.init(referenceOrCopy)
        deallocator()
    }
}
