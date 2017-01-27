//
//  Decode.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 27/1/17.
//
//

internal func bdecode(_ data: Data, _ index: Data.Index) throws -> (match: Bencode, index: Data.Index) {
    guard !data.isEmpty else {
        throw BencodingError.emptyString
    }
    
    let character = data[index]
    
    switch character {
    case UInt8("d"):
        return try bdecodeDictionary(data, index)
    case UInt8("i"):
        return try bdecodeInteger(data, index)
    case UInt8("0")...UInt8("9"):
        return try bdecodeString(data, index)
    case UInt8("l"):
        return try bdecodeList(data, index)
    default:
        throw BencodingError.unexpectedCharacter(Character(UnicodeScalar(character)), index)
    }
}
