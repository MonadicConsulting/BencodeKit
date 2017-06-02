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

internal extension Data {
    var asciiString: String {
        return reduce("") { string, byte in
            string.appendingFormat("%c", byte)
        }
    }
}

internal extension Sequence {
    func reduce<A>(into initial: A, _ combine: (inout A, Iterator.Element) -> ()) -> A {
        var result = initial
        for element in self {
            combine(&result, element)
        }
        return result
    }

    func all(where predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Bool {
        var returnValue = true
        for value in self {
            if try !predicate(value) {
                returnValue = false
                break
            }
        }
        return returnValue
    }
}
