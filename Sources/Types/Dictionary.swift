//
//  Dictionary.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 27/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

func bdecodeDictionary(_ string: String, _ index: String.Index) throws -> (Bencode, String.Index) {
    guard string[index] == "d" else {
        throw BencodingError.invalidDictionary(index)
    }
    
    var currentIndex = string.index(after: index)
    guard currentIndex != string.endIndex else {
        throw BencodingError.unterminatedDictionary(index)
    }
    
    var values: [(String, Bencode)] = []
    while string[currentIndex] != "e" {
        let (keyMatch, valueIndex) = try bdecode(string, currentIndex)
        guard case .string(let key) = keyMatch else {
            throw BencodingError.nonStringDictionaryKey(currentIndex)
        }

        let (valueMatch, nextIndex) = try bdecode(string, valueIndex)
        values.append((key, valueMatch))
        currentIndex = nextIndex
        guard currentIndex != string.endIndex else {
            throw BencodingError.unterminatedDictionary(index)
        }
    }
    
    return (.dictionary(values), string.index(after: currentIndex))
}
