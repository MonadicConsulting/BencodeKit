//
//  List.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 27/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

func bdecodeList(_ data: Data, _ index: Data.Index) throws -> (Bencode, Data.Index) {
    guard data[index] == "l" else {
        throw BencodingError.invalidList(index)
    }
    
    var currentIndex = data.index(after: index)
    guard currentIndex != data.endIndex else {
        throw BencodingError.unterminatedDictionary(index)
    }
    
    var values: [Bencode] = []
    while !(data[currentIndex] == "e") {
        let (match, index) = try bdecode(data, currentIndex)
        values.append(match)
        currentIndex = index
        guard currentIndex != data.endIndex else {
            throw BencodingError.unterminatedList(index)
        }
    }
    return (.list(values), data.index(after: currentIndex))
}
