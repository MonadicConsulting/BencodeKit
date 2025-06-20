//
//  Dictionary.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 27/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

import Foundation

public struct OrderedDictionary<Key: Hashable, Value>: Collection {
    public typealias Index = Int
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
    public var startIndex: Index {
        return 0
    }
    
    public var endIndex: Index {
        return keys.count
    }
    
    public var keys: Array<Key> = []
    public var values: Array<Value> {
        return keys.flatMap { dictionary[$0] }
    }
    private var dictionary: Dictionary<Key, Value> = [:]
    
    public init(_ elements: [(Key, Value)] = []) {
        self.keys = elements.map { $0.0 }
        self.dictionary = Dictionary(uniqueKeysWithValues: elements)
    }
    
    public init(_ elements: (Key, Value)...) {
        self.init(elements)
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return dictionary[key]
        }
        set(newValue) {
            if let value = newValue {
                if dictionary.updateValue(value, forKey: key) == nil {
                    keys.append(key)
                }
            } else {
                dictionary.removeValue(forKey: key)
                keys = keys.filter { $0 != key }
            }
        }
    }
    
    public subscript(index: Index) -> (Key, Value) {
        get {
            let key = keys[index]
            return (key, dictionary[key]!)
        }
    }
}

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
        values.append((stringKey, valueMatch))
        currentIndex = nextIndex
        guard currentIndex != data.endIndex else {
            throw BencodingError.unterminatedDictionary(index)
        }
    }
    
    return (.dictionary(OrderedDictionary(values)), data.index(after: currentIndex))
}
