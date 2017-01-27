//
//  Integer.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 26/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

func bdecodeInteger(_ string: String, _ index: String.Index) throws -> (match: Bencode, index: String.Index) {
    guard string[index] == "i" else {
        throw BencodingError.invalidInteger(index)
    }
    
    let integerIndex = string.index(after: index)
    guard let (eOffset, _) = string.substring(from: index).characters.enumerated().first(where: { $1 == "e" }) else {
        throw BencodingError.unterminatedInteger(index)
    }
    
    let eIndex = string.index(index, offsetBy: eOffset)
    let integerString = string.substring(with: Range(uncheckedBounds: (integerIndex, eIndex)))
    guard !integerString.hasPrefix("-0") else {
        throw BencodingError.negativeZeroEncountered(index)
    }
    
    guard let value = Int(integerString) else {
        throw BencodingError.contaminatedInteger(index)
    }

    return (.integer(value), string.index(after: eIndex))
}
