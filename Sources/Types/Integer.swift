//
//  Integer.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 26/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

func bdecodeInteger(_ data: Data, _ index: Data.Index) throws -> (match: Bencode, index: Data.Index) {
    guard data[index] == "i" else {
        throw BencodingError.invalidInteger(index)
    }
    
    let integerIndex = data.index(after: index)
    guard let (eOffset, _) = data.subdata(in: Range(uncheckedBounds: (index, data.endIndex))).enumerated().first(where: { $1 == "e" }) else {
        throw BencodingError.unterminatedInteger(index)
    }
    let eIndex = data.index(index, offsetBy: eOffset)
    let integerData = data.subdata(in: Range(uncheckedBounds: (integerIndex, eIndex)))
    guard let integerString = String(bytes: integerData, encoding: .ascii), !integerString.hasPrefix("-0") else {
        throw BencodingError.negativeZeroEncountered(index)
    }
    
    print(integerString)
    
    guard let value = Int(integerString) else {
        throw BencodingError.contaminatedInteger(index)
    }

    return (.integer(value), data.index(after: eIndex))
}
