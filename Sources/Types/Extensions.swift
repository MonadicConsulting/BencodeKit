//
//  Extensions.swift
//  BencodeKit
//
//  Created by Charlotte Tortorella on 27/1/17.
//
//

func ==(lhs: Character, rhs: UInt8) -> Bool {
    return lhs == Character(UnicodeScalar(rhs))
}

func ==(lhs: UInt8, rhs: Character) -> Bool {
    return rhs == lhs
}

internal extension UInt8 {
    init(_ character: String) {
        self = UInt8(character.unicodeScalars.first!.value)
    }
}

internal extension String {
    var asciiData: Data {
        return data(using: .ascii)!
    }
}
