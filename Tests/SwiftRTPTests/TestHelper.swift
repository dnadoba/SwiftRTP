//
//  File.swift
//  
//
//  Created by David Nadoba on 09.04.20.
//

import Foundation
import SwiftRTP

extension RTPPayloadType: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: RawValue) {
        self.init(rawValue: value)
    }
}
extension RTPSynchronizationSource: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: RawValue) {
        self.init(rawValue: value)
    }
}
extension RTPContributingSource: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: RawValue) {
        self.init(rawValue: value)
    }
}


extension RandomAccessCollection {
    public subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
