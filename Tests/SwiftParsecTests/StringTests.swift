// ==============================================================================
// StringTests.swift
// SwiftParsec
//
// Created by David Dufresne on 2016-05-25.
// Copyright © 2016 David Dufresne. All rights reserved.
// ==============================================================================

import XCTest
@testable import SwiftParsec

class StringTests: XCTestCase {
    func testLast() {
        let str = "1234"
        XCTAssertEqual(
            "4",
            str.last!,
            "`str.last` should return \"4\"."
        )

        let emptyStr = ""
        XCTAssertNil(
            emptyStr.last,
            "`emptyStr.last` should return `nil`."
        )
    }
}

extension StringTests {
    static var allTests: [(String, (StringTests) -> () throws -> Void)] {
        return [("testLast", testLast)]
    }
}
