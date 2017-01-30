//
//  Bencode.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 25/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

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
    case nonAsciiDictionaryKey(Data.Index)
    case unterminatedDictionary(Data.Index)
    case nonAsciiString
}

public indirect enum Bencode: Equatable {
    case integer(Int)
    case bytes(Data)
    case list([Bencode])
    case dictionary([(String, Bencode)])
    
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
        self = .dictionary(dictionary)
    }
    
    func stringRepresentation() throws -> String {
        switch self {
        case .integer(let integer):
            return "i\(String(integer))e"
        case .bytes(let bytes):
            guard let string = String(bytes: bytes, encoding: .ascii) else { throw BencodingError.nonAsciiString }
            return "\(string.characters.count):\(string)"
        case .list(let list):
            return try "l\(list.map({ try $0.stringRepresentation() }).joined())e"
        case .dictionary(let dictionary):
            return try "d\(dictionary.map({ "\($0.characters.count):\($0)\(try $1.stringRepresentation())" }).joined())e"
        }
    }
}

public extension Bencode {
    public static func decode(_ data: Data) throws -> Bencode {
        return try bdecode(data, data.startIndex).match
    }
}

public extension Bencode {
    public static func decodeFile(atPath path: String) throws -> Bencode {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw BencodingError.nonExistentFile(path)
        }
        return try decode(data)
    }
}

public extension Bencode {
    public func encoded() -> Data {
        switch self {
        case .integer(let integer):
            return "i\(String(integer))e".asciiData
        case .bytes(let bytes):
            return "\(bytes.count):".asciiData + bytes
        case .list(let list):
            return "l".asciiData + list.map({ $0.encoded() }).joined() + "e".asciiData
        case .dictionary(let dictionary):
            return "d".asciiData + dictionary.map({ "\($0.characters.count):\($0)".asciiData + $1.encoded() }).joined() + "e".asciiData
        }
    }
}

public extension Bencode {
    public static func ==(lhs: Bencode, rhs: Bencode) -> Bool {
        switch (lhs, rhs) {
        case (.integer(let a), .integer(let b)):
            return a == b
        case (.bytes(let a), .bytes(let b)):
            return a == b
        case (.list(let a), .list(let b)):
            return a.count == b.count && zip(a, b).reduce(true, { $0 && ($1.0 == $1.1) })
        case (.dictionary(let a), .dictionary(let b)):
            return a.count == b.count && zip(a, b).reduce(true, { $0 && ($1.0 == $1.1) })
        case _:
            return false
        }
    }
}
