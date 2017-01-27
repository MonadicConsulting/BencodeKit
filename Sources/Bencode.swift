//
//  Bencode.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 25/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

public enum BencodingError: Error {
    case emptyString
    case unexpectedCharacter(Character, String.Index)
    case negativeZeroEncountered(String.Index)
    case invalidStringLength(String.Index)
    case invalidInteger(String.Index)
    case contaminatedInteger(String.Index)
    case unterminatedInteger(String.Index)
    case invalidList(String.Index)
    case unterminatedList(String.Index)
    case invalidDictionary(String.Index)
    case nonStringDictionaryKey(String.Index)
    case unterminatedDictionary(String.Index)
}

public indirect enum Bencode: Equatable {
    case integer(Int)
    case string(String)
    case list([Bencode])
    case dictionary([(String, Bencode)])
}

public extension Bencode {
    public static func decode(_ string: String) throws -> Bencode {
        return try bdecode(string, string.startIndex).match
    }
}

public extension Bencode {
    public func encoded() -> String {
        switch self {
        case .integer(let integer):
            return "i\(String(integer))e"
        case .string(let string):
            return "\(string.characters.count):\(string)"
        case .list(let list):
            return "l\(list.map({ $0.encoded() }).joined())e"
        case .dictionary(let dictionary):
            return "d\(dictionary.map({ "\($0.characters.count):\($0)\($1.encoded())" }).joined())e"
        }
    }
}

public extension Bencode {
    public static func ==(lhs: Bencode, rhs: Bencode) -> Bool {
        switch (lhs, rhs) {
        case (.integer(let a), .integer(let b)):
            return a == b
        case (.string(let a), .string(let b)):
            return a == b
        case (.list(let a), .list(let b)):
            return a.count == b.count && zip(a, b).reduce(true, { $0 && ($1.0 == $1.1) })
        case (.dictionary(let a), .dictionary(let b)):
            return a.count == b.count && zip(a, b).reduce(true, { $0 && ($1.0 == $1.1) })
        case (_, _):
            return false
        }
    }
}

internal func bdecode(_ string: String, _ index: String.Index) throws -> (match: Bencode, index: String.Index) {
    guard !string.isEmpty else {
        throw BencodingError.emptyString
    }
    
    let character = string[index]
    
    switch character {
    case "d":
        return try bdecodeDictionary(string, index)
    case "i":
        return try bdecodeInteger(string, index)
    case "0"..."9":
        return try bdecodeString(string, index)
    case "l":
        return try bdecodeList(string, index)
    default:
        throw BencodingError.unexpectedCharacter(character, index)
    }
}
