//
//  Tests.swift
//  BencodeKit-Tests
//
//  Created by Charlotte Tortorella on 25/1/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

import Foundation
import XCTest
@testable import BencodeKit

class BencodeKitTests: XCTestCase {
    
    func testStringParsing() {
        let data = "12:123456789123".data(using: .ascii)!
        let (match, _) = try! bdecodeString(data, data.startIndex)
        print(match.description)
//        testParsing("12:123456789123", .bytes("123456789123"))
        
        expectException("-13:40")
        expectException("-13:40")
        expectException("-13:40")
        expectException("-13:40")
        expectException("4:lkd")
    }
    
    func testListParsing() {
        testParsing("li-123456789e4:nulle", Bencode([.integer(-123456789), Bencode("null")!]))
        compareToReencoding("li-123456789e4:nulle")
    }
    
    func testDictionaryParsing() {
        testParsing("d4:nulli-123456789e2:hilee", .dictionary([("null", .integer(-123456789)), ("hi", .list([]))]))
        compareToReencoding("d4:nulli-123456789e2:hilee")
        
        expectException("d")
    }
    
    func testIntegerParsing() {
        let data = "i-123456789e".data(using: .ascii)!
        print(try! bdecodeInteger(data, data.startIndex))
        
        testParsing("i-123456789e", .integer(-123456789))
        
        expectException("ie")
        expectException("i-0e")
        expectException("ioe")
        expectException("ize")
        expectException("id")
        expectException("i")
    }
    
    func testTorrentFiles() {
        Bundle(for: type(of: self))
            .paths(forResourcesOfType: "torrent", inDirectory: "Torrents")
            .flatMap(FileManager.default.contents)
            .forEach { encoded in
                let decoded = try! Bencode.decode(encoded)
                print(decoded.description)
                let reEncoded = decoded.encoded()
                XCTAssertEqual(encoded, reEncoded)
        }
    }
}

func compareToReencoding(_ param: String) {
    let data = param.asciiData
    let returnedData = try! Bencode.decode(data).encoded()
    XCTAssertEqual(returnedData, data)
}

func testParsing(_ param: String, _ compareTo: Bencode) {
    XCTAssertEqual(try! Bencode.decode(param.asciiData), compareTo)
}

func expectException(_ param: String) {
    do {
        _ = try Bencode.decode(param.asciiData)
        XCTFail()
    } catch {}
}
