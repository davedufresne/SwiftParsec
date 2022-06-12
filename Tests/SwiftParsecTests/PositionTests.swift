// ==============================================================================
// PositionTests.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-11-13.
// Copyright © 2015 David Dufresne. All rights reserved.
// ==============================================================================

import XCTest
@testable import SwiftParsec

class PositionTests: XCTestCase {
    func testComparable() {
        let pos1 = SourcePosition(name: "", line: 1, column: 8)
        let pos2 = SourcePosition(name: "", line: 2, column: 1)
        let pos3 = SourcePosition(name: "", line: 1, column: 4)

        XCTAssert(pos1 < pos2, "pos1 should be smaller than pos2.")
        XCTAssertFalse(pos2 < pos1, "pos2 should be greater than pos1.")
        XCTAssert(pos1 == pos1, "pos1 should be equal to itself.")
        XCTAssert(pos1 > pos3, "pos1 should be greater than pos3.")
        XCTAssertFalse(pos3 > pos1, "pos3 should be smaller than pos1.")
    }

    func testColumnPosition() {
        let str = "1234"
        let expectedColumn = str.count + 1

        let strParser = StringParser.string(str)
        let positionParser = strParser *>
            GenericParser<String, (), SourcePosition>.sourcePosition

        let errorMessage = "GenericParser.sourcePosition should return " +
            "column value equal to \"\(expectedColumn)\"."

        testStringParserSuccess(positionParser, inputs: [str]) { input, result in
            XCTAssertEqual(
                expectedColumn,
                result.column,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testLineColumnPosition() {
        let str = "1\n2\n3"
        let expectedLine = 3
        let expectedColumn = 2

        let strParser = StringParser.string(str)
        let positionParser = strParser *>
            GenericParser<String, (), SourcePosition>.sourcePosition

        let errorMessage = "GenericParser.sourcePosition should return " +
            "line value equal to \"\(expectedLine)\" and column value equal " +
            "to \"\(expectedLine)\"."

        testStringParserSuccess(positionParser, inputs: [str]) { input, result in
            let positionEqual = expectedLine == result.line &&
                expectedColumn == result.column

            XCTAssert(
                positionEqual,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testTabPosition() {
        let str = "1\t3"
        let expectedColumn = 10

        let strParser = StringParser.string(str)
        let positionParser = strParser *>
            GenericParser<String, (), SourcePosition>.sourcePosition

        let errorMessage = "GenericParser.sourcePosition should return " +
            "column value equal to \"\(expectedColumn)\"."

        testStringParserSuccess(positionParser, inputs: [str]) { input, result in
            XCTAssertEqual(
                expectedColumn,
                result.column,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }
}

extension PositionTests {
    static var allTests: [(String, (PositionTests) -> () throws -> Void)] {
        return [
            ("testComparable", testComparable),
            ("testColumnPosition", testColumnPosition),
            ("testLineColumnPosition", testLineColumnPosition),
            ("testTabPosition", testTabPosition)
        ]
    }
}
