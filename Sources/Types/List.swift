//
//  List.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 27/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

func bdecodeList(_ string: String, _ index: String.Index) throws -> (Bencode, String.Index) {
    guard string[index] == "l" else {
        throw BencodingError.invalidList(index)
    }
    
    var currentIndex = string.index(after: index)
    guard currentIndex != string.endIndex else {
        throw BencodingError.unterminatedDictionary(index)
    }
    
    var values: [Bencode] = []
    while string[currentIndex] != "e" {
        let (match, index) = try bdecode(string, currentIndex)
        values.append(match)
        currentIndex = index
        guard currentIndex != string.endIndex else {
            throw BencodingError.unterminatedList(index)
        }
    }
    
    return (.list(values), string.index(after: currentIndex))
}
