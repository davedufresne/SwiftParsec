// ==============================================================================
// CharacterSetTests.swift
// SwiftParsec
// ==============================================================================

import XCTest
@testable import SwiftParsec

class CharacterSetTests: XCTestCase {
    // Creating large `Foundation.CharacterSet`s can cause Linux programs to
    // halt (silently crash).
    func testLarge() {
        // Initialized this way to overcome Swift 4.2 compiler error
        let unicode: String = {
            let strands: [String] = [
                (0x10000...0x1FFFD).stringValue,
                (0x20000...0x2FFFD).stringValue,
                (0x30000...0x3FFFD).stringValue,
                (0x40000...0x4FFFD).stringValue,
                (0x50000...0x5FFFD).stringValue,
                (0x60000...0x6FFFD).stringValue,
                (0x70000...0x7FFFD).stringValue,
                (0x80000...0x8FFFD).stringValue,
                (0x90000...0x9FFFD).stringValue,
                (0xA0000...0xAFFFD).stringValue,
                (0xB0000...0xBFFFD).stringValue,
                (0xC0000...0xCFFFD).stringValue,
                (0xD0000...0xDFFFD).stringValue,
                (0xE0000...0xEFFFD).stringValue
            ]
            return strands.reduce(into: "") { $0 += $1 }
        }()
        _ = CharacterSet(charactersIn: unicode)
    }
}

extension CharacterSetTests {
    static var allTests: [(String, (CharacterSetTests) -> () throws -> Void)] {
        return [("testLarge", testLarge)]
    }
}
