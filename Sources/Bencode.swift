//
//  Bencode.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 25/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

import Foundation
import CryptoKit

public enum BencodingError: Error {
    case emptyString
    case nonExistentFile(String)
    case unexpectedCharacter(Character, Data.Index)
    case negativeZeroEncountered(Data.Index)
    case invalidStringLength(Data.Index)
    case invalidInteger(Data.Index)
    case contaminatedInteger(Data.Index)
    case unterminatedInteger(Data.Index)
    case invalidList(Data.Index)
    case unterminatedList(Data.Index)
    case invalidDictionary(Data.Index)
    case nonStringDictionaryKey(Data.Index)
    case unterminatedDictionary(Data.Index)
    case nonAsciiString
}

public indirect enum Bencode: Equatable {
    case integer(Int)
    case bytes(Data)
    case list([Bencode])
    case dictionary(OrderedDictionary<String, Bencode>)
    
    init(_ integer: Int) {
        self = .integer(integer)
    }
    
    init(_ string: String) throws {
        guard let value = string.data(using: .ascii) else { throw BencodingError.nonAsciiString }
        self = .bytes(value)
    }
    
    init(_ bytes: Data) {
        self = .bytes(bytes)
    }
    
    init(_ list: [Bencode]) {
        self = .list(list)
    }
    
    init(_ dictionary: [(String, Bencode)]) {
        self.init(OrderedDictionary<String, Bencode>(dictionary))
    }
    
    init(_ dictionary: OrderedDictionary<String, Bencode>) {
        self = .dictionary(dictionary)
    }
    
    public func encodedString() -> String {
        switch self {
        case .integer(let integer):
            return "i\(String(integer))e"
        case .bytes(let bytes):
            let string = bytes.asciiString
            return "\(string.count):\(string)"
        case .list(let list):
            return "l\(list.map { $0.encodedString() }.joined())e"
        case .dictionary(let dictionary):
            return "d\(dictionary.map { "\($0.count):\($0)\($1.encodedString())" }.joined())e"
        }
    }
    
    public func toString() -> String {
        switch self {
        case .integer(let integer):
            return String(integer)
        case .bytes(let bytes):
            return bytes.asciiString
        case .list(let list):
            return "[" + list.map { $0.toString() }.joined(separator: ", ") + "]"
        case .dictionary(let dictionary):
            return "[" + dictionary.map { "\"\($0)\": \($1.toString())" }.joined(separator: ", ") + "]"
        }

    }
    
    public subscript(index: String) -> Bencode? {
        get {
            guard case .dictionary(let dictionary) = self else {
                return nil
            }
            return dictionary[index]
        }
    }
}

public extension Bencode {
    static func decode(_ data: Data) throws -> Bencode {
        return try bdecode(data, data.startIndex).match
    }
}

public extension Bencode {
    static func decodeFile(atPath path: String) throws -> Bencode {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw BencodingError.nonExistentFile(path)
        }
        return try decode(data)
    }
}

public extension Bencode {
    func encoded() -> Data {
        switch self {
        case .integer(let integer):
            return "i\(String(integer))e".asciiData
        case .bytes(let bytes):
            return "\(bytes.count):".asciiData + bytes
        case .list(let list):
            return "l".asciiData + list.map { $0.encoded() }.joined() + "e".asciiData
        case .dictionary(let dictionary):
            return "d".asciiData + dictionary.map { "\($0.count):\($0)".asciiData + $1.encoded() }.joined() + "e".asciiData
        }
    }
}

public extension Bencode {
    func sha1Hash() -> String {
        Insecure.SHA1
            .hash(data: encoded())
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

public extension Bencode {
    static func ==(lhs: Bencode, rhs: Bencode) -> Bool {
        switch (lhs, rhs) {
        case (.integer(let a), .integer(let b)):
            return a == b
        case (.bytes(let a), .bytes(let b)):
            return a == b
        case (.list(let a), .list(let b)) where a.count == b.count:
            return zip(a, b).all(where: ==)
        case (.dictionary(let a), .dictionary(let b)) where a.count == b.count:
            return zip(a, b).all(where: ==)
        default:
            return false
        }
    }
}
