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
    
    func testDecoding() {
        expectException("")
        expectException("k")
        _ = Bencode("hello".asciiData)
        XCTAssertNotEqual(Bencode(0), try! Bencode("4:null"))
        expectException(try Bencode.decodeFile(atPath: ""))
    }
    
    func testStringParsing() {
        testParsing("12:123456789123", try! Bencode("123456789123"))
        
        expectException("-13:40", bdecodeString)
        expectException("4:lkd")
        expectException("4e:lkd")
        expectException("i0e", bdecodeString)
    }
    
    func testListParsing() {
        testParsing("li-123456789e4:nulle", try! Bencode([.integer(-123456789), Bencode("null")]))
        compareToReencoding("li-123456789e4:nulle")
        expectException("l")
        expectException("li0e")
        expectException("i0e", bdecodeList)
    }
    
    func testDictionaryParsing() {
        _ = Bencode([("", Bencode(0))])
        testParsing("d4:nulli-123456789e2:hilee", .dictionary(BencodeDictionary([("null", .integer(-123456789)), ("hi", .list([]))])))
        testParsing("de", .dictionary(BencodeDictionary()))
        compareToReencoding("d4:nulli-123456789e2:hilee")
        compareToReencoding("de")
        compareToReencoding("d5:hello5:theree")
        
        expectException("d")
        expectException("di0e4:nulle")
        expectException("d4:nulli0e")
        expectException("i0e", bdecodeDictionary)
    }
    
    func testIntegerParsing() {
        _ = Bencode(0)
        testParsing("i-123456789e", .integer(-123456789))
        compareToReencoding("i-123456789e")
        expectException("de", bdecodeInteger)
        expectException("ie")
        expectException("i-0e")
        expectException("ioe")
        expectException("ize")
        expectException("id")
        expectException("i")
    }
    
    func testTorrentFiles() {
        let filePaths = Bundle(for: type(of: self)).paths(forResourcesOfType: "torrent", inDirectory: "Torrents")
        filePaths
            .flatMap(FileManager.default.contents)
            .forEach { encoded in
                let decoded = try! Bencode.decode(encoded)
                let reEncoded = decoded.encoded()
                XCTAssertEqual(encoded, reEncoded)
                _ = decoded.encodedString()
        }
        filePaths
            .map { try! Bencode.decodeFile(atPath: $0) }
            .forEach { decoded in
                _ = decoded.encodedString()
        }
    }
    
    func testDecodeTime() {
        let filePath = Bundle(for: type(of: self)).paths(forResourcesOfType: "torrent", inDirectory: "Torrents").first!
        let encoded = FileManager.default.contents(atPath: filePath)!
        self.measure {
            _ = try! Bencode.decode(encoded)
        }
    }
    
    func testEncodeTime() {
        let filePath = Bundle(for: type(of: self)).paths(forResourcesOfType: "torrent", inDirectory: "Torrents").first!
        let encoded = FileManager.default.contents(atPath: filePath)!
        let decoded = try! Bencode.decode(encoded)
        self.measure {
            _ = decoded.encoded()
        }
    }
    
    func testStringifyTime() {
        let filePath = Bundle(for: type(of: self)).paths(forResourcesOfType: "torrent", inDirectory: "Torrents").first!
        let encoded = FileManager.default.contents(atPath: filePath)!
        let decoded = try! Bencode.decode(encoded)
        self.measure {
            _ = decoded.encodedString()
        }
    }
    
    func testSha1() {
        let filePaths = Bundle(for: type(of: self)).paths(forResourcesOfType: "torrent", inDirectory: "Torrents")
        filePaths
            .flatMap(FileManager.default.contents)
            .forEach { encoded in
                let decoded = try! Bencode.decode(encoded)
                _ = decoded.toString()
                print(decoded["info"]!["name"]!.toString())
                print(decoded["info"]!.sha1Hash())
        }
    }
}

func compareToReencoding(_ param: String) {
    let data = param.asciiData
    let decoded = try! Bencode.decode(data)
    XCTAssertEqual(data, decoded.encoded())
    XCTAssertEqual(param, decoded.encodedString())
}

func testParsing(_ param: String, _ compareTo: Bencode) {
    XCTAssertEqual(try! Bencode.decode(param.asciiData), compareTo)
}

func expectException(_ param: String, _ f: (Data, Data.Index) throws -> (Bencode, Data.Index) = { data, index in try (Bencode.decode(data), 0) }) {
    do {
        let data = param.asciiData
        _ = try f(data, data.startIndex)
        XCTFail()
    } catch {}
}

func expectException<T>(_ f: @autoclosure () throws -> T) {
    do {
        _ = try f()
        XCTFail()
    } catch {}
}
