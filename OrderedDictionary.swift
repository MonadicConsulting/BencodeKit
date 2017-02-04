//
//  OrderedDictionary.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 1/2/17.
//
//

import Foundation

public struct BencodeDictionary: Collection {
    public func index(after i: Index) -> Index {
        return i + 1
    }

    public var startIndex: Index {
        return 0
    }
    
    public var endIndex: Index {
        return elements.count
    }

    private var elements: [(String, Bencode)] = []
    
    public typealias Index = Int
    
    var keys: [String] {
        return elements.map { $0.0 }
    }
    
    var values: [Bencode] {
        return elements.map { $0.1 }
    }
    
    init(_ elements: [(String, Bencode)] = []) {
        self.elements = elements
    }
    
    mutating func update(value: Bencode?, forKey key: String) {
        elements = elements.filter { $0.0 != key }
        if let value = value {
            elements.append(key, value)
        }
    }
    
    func value(forKey key: String) -> Bencode? {
        return elements.first { $0.0 == key }?.1
    }
    
    public subscript(index: String) -> Bencode? {
        get {
            return value(forKey: index)
        }
        set(newValue) {
            update(value: newValue, forKey: index)
        }
    }
    
    public subscript(index: Index) -> (String, Bencode) {
        get {
            return elements[index]
        }
        set(newValue) {
            elements[index] = newValue
        }
    }
}
