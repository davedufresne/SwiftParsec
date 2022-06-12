// ==============================================================================
// UnicodeScalarTests.swift
// SwiftParsec
//
// Created by David Dufresne on 2016-05-10.
// Copyright © 2016 David Dufresne. All rights reserved.
// ==============================================================================

import XCTest
@testable import SwiftParsec

private let maxCodePointValue = 0x10FFFF
private let minSurrogatePairValue = 0xD800
private let maxSurrogatePairValue = 0xDFFF

class UnicodeScalarTests: XCTestCase {
    func testFromInt() {
        // Test boundary conditions

        let aboveMax = UnicodeScalar.fromInt(maxCodePointValue + 1)
        XCTAssertNil(
            aboveMax,
            "UnicodeScalar.fromInt should return nil when above maximum value."
        )

        let belowMin = UnicodeScalar.fromInt(-1)
        XCTAssertNil(
            belowMin,
            "UnicodeScalar.fromInt should return nil when below minimm value."
        )

        let minSurrogatePair = UnicodeScalar.fromInt(minSurrogatePairValue)
        XCTAssertNil(
            minSurrogatePair,
            "UnicodeScalar.fromInt should return nil when a surrogate pair."
        )

        let maxSurrogatePair = UnicodeScalar.fromInt(maxSurrogatePairValue)
        XCTAssertNil(
            maxSurrogatePair,
            "UnicodeScalar.fromInt should return nil when a surrogate pair."
        )
    }

    func testFromUInt32() {
        // Test boundary conditions

        let aboveMax = UnicodeScalar.fromUInt32(UInt32(maxCodePointValue) + 1)
        XCTAssertNil(
            aboveMax,
            "UnicodeScalar.fromUInt32 should return nil when above maximum " +
                "value."
        )

        let minSurrogatePair = UnicodeScalar.fromUInt32(
            UInt32(minSurrogatePairValue)
        )
        XCTAssertNil(
            minSurrogatePair,
            "UnicodeScalar.fromUInt32 should return nil when a surrogate pair."
        )

        let maxSurrogatePair = UnicodeScalar.fromUInt32(
            UInt32(maxSurrogatePairValue)
        )
        XCTAssertNil(
            maxSurrogatePair,
            "UnicodeScalar.fromUInt32 should return nil when a surrogate pair."
        )
    }
}

extension UnicodeScalarTests {
    static var allTests: [(String, (UnicodeScalarTests) -> () throws -> Void)] {
        return [
            ("testFromInt", testFromInt),
            ("testFromUInt32", testFromUInt32)
        ]
    }
}
