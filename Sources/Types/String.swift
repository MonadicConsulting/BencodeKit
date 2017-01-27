//
//  String.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 26/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

internal func bdecodeString(_ string: String, _ index: String.Index) throws -> (match: Bencode, index: String.Index) {
    guard let (colonOffset, _) = string.substring(from: index).characters.enumerated().first(where: { $1 == ":" }) else {
        throw BencodingError.invalidStringLength(index)
    }
    
    let colonIndex = string.index(index, offsetBy: colonOffset)
    let restIndex = string.index(after: colonIndex)
    
    guard let length = UInt(string.substring(with: Range(uncheckedBounds: (index, colonIndex)))).map({ Int($0) }) else {
        throw BencodingError.invalidStringLength(index)
    }
    
    guard let lastIndex = string.index(restIndex, offsetBy: length, limitedBy: string.endIndex) else {
        throw BencodingError.invalidStringLength(index)
    }
    
    let value = string.substring(with: Range(uncheckedBounds: (restIndex, lastIndex)))
    return (.string(value), string.index(restIndex, offsetBy: length))
}
