//
//  Dictionary.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 27/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

internal func bdecodeDictionary(_ data: Data, _ index: Data.Index) throws -> (Bencode, Data.Index) {
    guard data[index] == "d" else {
        throw BencodingError.invalidDictionary(index)
    }
    
    var currentIndex = data.index(after: index)
    guard currentIndex != data.endIndex else {
        throw BencodingError.unterminatedDictionary(index)
    }
    
    var values: [(String, Bencode)] = []
    while !(data[currentIndex] == "e") {
        let (keyMatch, valueIndex) = try bdecode(data, currentIndex)
        guard case .bytes(let key) = keyMatch else {
            throw BencodingError.nonStringDictionaryKey(currentIndex)
        }

        let (valueMatch, nextIndex) = try bdecode(data, valueIndex)
        
        let stringKey = key.reduce("") { string, byte in
            string.appendingFormat("%c", byte)
        }
        values.append(stringKey, valueMatch)
        currentIndex = nextIndex
        guard currentIndex != data.endIndex else {
            throw BencodingError.unterminatedDictionary(index)
        }
    }
    
    return (.dictionary(BencodeDictionary(values)), data.index(after: currentIndex))
}
