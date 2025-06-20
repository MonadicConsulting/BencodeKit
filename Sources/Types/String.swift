//
//  String.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 26/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

import Foundation

internal func bdecodeString(_ data: Data, _ index: Data.Index) throws -> (match: Bencode, index: Data.Index) {
    guard let (colonOffset, _) = data.subdata(in: Range(uncheckedBounds: (index, data.endIndex))).enumerated().first(where: { $1 == ":" }) else {
        throw BencodingError.invalidStringLength(index)
    }
    
    let colonIndex = data.index(index, offsetBy: colonOffset)
    let restIndex = data.index(after: colonIndex)
    let lengthString = String(bytes: data.subdata(in: Range(uncheckedBounds: (index, colonIndex))), encoding: .ascii)
    
    guard let length = lengthString.flatMap({ UInt($0) }).map({ Int($0) }) else {
        throw BencodingError.invalidStringLength(index)
    }
    
    guard let lastIndex = data.index(restIndex, offsetBy: length, limitedBy: data.endIndex) else {
        throw BencodingError.invalidStringLength(index)
    }
    
    let value = data.subdata(in: Range(uncheckedBounds: (restIndex, lastIndex)))
    return (.bytes(value), data.index(restIndex, offsetBy: length))
}
