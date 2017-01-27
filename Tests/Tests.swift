//
//  Tests.swift
//  BencodeKit-Tests
//
//  Created by Charlotte Tortorella on 25/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

import XCTest
@testable import BencodeKit

class BencodeKitTests: XCTestCase {
    
    func testStringParsing() {
        testParsing("12:123456789123", .string("123456789123"))
        
        expectException("-13:40")
        expectException("-13:40")
        expectException("-13:40")
        expectException("-13:40")
        expectException("4:lkd")
    }
    
    func testListParsing() {
        testParsing("li-123456789e4:nulle", .list([.integer(-123456789), .string("null")]))
        compareToReencoding("li-123456789e4:nulle")
    }
    
    func testDictionaryParsing() {
        testParsing("d4:nulli-123456789e2:hilee", .dictionary([("null", .integer(-123456789)), ("hi", .list([]))]))
        compareToReencoding("d4:nulli-123456789e2:hilee")
        
        expectException("d")
    }
    
    func testIntegerParsing() {
        testParsing("i-123456789e", .integer(-123456789))
        
        expectException("ie")
        expectException("i-0e")
        expectException("ioe")
        expectException("ize")
        expectException("id")
        expectException("i")
    }
}

func compareToReencoding(_ param: String) {
    XCTAssertEqual(try! Bencode.decode(param).encoded(), param)
}

func testParsing(_ param: String, _ compareTo: Bencode) {
    XCTAssertEqual(try! Bencode.decode(param), compareTo)
}

func expectException(_ param: String) {
    do {
        _ = try Bencode.decode(param)
        XCTFail()
    } catch {}
}
