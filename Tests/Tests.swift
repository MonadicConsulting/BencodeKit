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
        testParsing("0:", try! Bencode(""))
        compareToReencoding("0:")
        
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
        testParsing("d4:nulli-123456789e2:hilee", .dictionary(OrderedDictionary([("null", .integer(-123456789)), ("hi", .list([]))])))
        testParsing("de", .dictionary(OrderedDictionary()))
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
        guard let resourceURL = Bundle.module.resourceURL?.appendingPathComponent("Torrents") else {
            XCTFail("Could not find Torrents directory")
            return
        }
        
        let fileManager = FileManager.default
        guard let torrentFiles = try? fileManager.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: [])
            .filter({ $0.pathExtension == "torrent" }) else {
            XCTFail("Could not read torrent files")
            return
        }
        
        for torrentURL in torrentFiles {
            guard let encoded = try? Data(contentsOf: torrentURL) else {
                XCTFail("Could not read torrent file: \(torrentURL)")
                continue
            }
            
            let decoded = try! Bencode.decode(encoded)
            let reEncoded = decoded.encoded()
            XCTAssertEqual(encoded, reEncoded)
            _ = decoded.encodedString()
        }
        
        for torrentURL in torrentFiles {
            let decoded = try! Bencode.decodeFile(atPath: torrentURL.path)
            _ = decoded.encodedString()
        }
    }
    
    func testDecodeTime() {
        guard let resourceURL = Bundle.module.resourceURL?.appendingPathComponent("Torrents"),
              let torrentFiles = try? FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: [])
                .filter({ $0.pathExtension == "torrent" }),
              let firstTorrent = torrentFiles.first,
              let encoded = try? Data(contentsOf: firstTorrent) else {
            XCTFail("Could not find torrent files for performance test")
            return
        }
        
        self.measure {
            _ = try! Bencode.decode(encoded)
        }
    }
    
    func testEncodeTime() {
        guard let resourceURL = Bundle.module.resourceURL?.appendingPathComponent("Torrents"),
              let torrentFiles = try? FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: [])
                .filter({ $0.pathExtension == "torrent" }),
              let firstTorrent = torrentFiles.first,
              let encoded = try? Data(contentsOf: firstTorrent) else {
            XCTFail("Could not find torrent files for performance test")
            return
        }
        
        let decoded = try! Bencode.decode(encoded)
        self.measure {
            _ = decoded.encoded()
        }
    }
    
    func testStringifyTime() {
        guard let resourceURL = Bundle.module.resourceURL?.appendingPathComponent("Torrents"),
              let torrentFiles = try? FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: [])
                .filter({ $0.pathExtension == "torrent" }),
              let firstTorrent = torrentFiles.first,
              let encoded = try? Data(contentsOf: firstTorrent) else {
            XCTFail("Could not find torrent files for performance test")
            return
        }
        
        let decoded = try! Bencode.decode(encoded)
        self.measure {
            _ = decoded.encodedString()
        }
    }
    
    func testSha1() {
        guard let resourceURL = Bundle.module.resourceURL?.appendingPathComponent("Torrents"),
              let torrentFiles = try? FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: [])
                .filter({ $0.pathExtension == "torrent" }) else {
            XCTFail("Could not find torrent files")
            return
        }
        
        for torrentURL in torrentFiles {
            guard let encoded = try? Data(contentsOf: torrentURL) else {
                continue
            }
            
            let decoded = try! Bencode.decode(encoded)
            _ = decoded.toString()
            print(decoded["info"]!["name"]!.toString())
            print(decoded["info"]!.sha1Hash())
        }
    }
    
    func testOrderedDictionary() {
        var dictionary = OrderedDictionary(("hello", try! Bencode("there")))
        XCTAssertEqual(dictionary["hello"], try! Bencode("there"))
        dictionary["hello"] = Bencode(0)
        dictionary["what"] = Bencode(10)
        XCTAssertEqual(dictionary["hello"], Bencode(0))
        XCTAssertEqual(dictionary["what"], Bencode(10))
        dictionary["what"] = nil
        XCTAssertEqual(dictionary["what"], nil)
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
