// ==============================================================================
// ErrorMessageTest.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-10-28.
// Copyright © 2015 David Dufresne. All rights reserved.
// ==============================================================================

import XCTest
@testable import SwiftParsec

class ErrorMessageTests: XCTestCase {
    func testCharacterError() {
        let vowel = StringParser.oneOf("aeiou")
        let expectedVowel = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\""

        errorMessageTest(vowel, input: "z") { actual in
            XCTAssertEqual(
                expectedVowel,
                actual,
                self.formatErrorMessage(
                    expected: expectedVowel,
                    actual: actual
                )
            )
        }

        let char = StringParser.character("a")
        let expectedChar = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting \"a\""

        errorMessageTest(char, input: "z") { actual in
            XCTAssertEqual(
                expectedChar,
                actual,
                self.formatErrorMessage(
                    expected: expectedChar,
                    actual: actual
                )
            )
        }
    }

    func testStringError() {
        let allo = StringParser.string("allo")
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting \"allo\""

        errorMessageTest(allo, input: "allz") { actual in
            XCTAssertEqual(
                expected,
                actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }
    }

    func testEofError() {
        let allo = StringParser.string("allo")
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""

        errorMessageTest(allo, input: "all") { actual in
            XCTAssertEqual(
                expected,
                actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }
    }

    func testChoiceError() {
        let allo = StringParser.string("allo")
        let hello = StringParser.string("hello")
        let hola = StringParser.string("hola")

        let hellos = allo <|> hello <|> hola

        let expectedHellos = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting \"allo\", \"hello\" or \"hola\""

        errorMessageTest(hellos, input: "z") { actual in
            XCTAssertEqual(
                expectedHellos,
                actual,
                self.formatErrorMessage(
                    expected: expectedHellos,
                    actual: actual
                )
            )
        }

        let expectedEOF = "\"test\" (line 1, column 1):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""

        errorMessageTest(hellos, input: "all") { actual in
            XCTAssertEqual(
                expectedEOF,
                actual,
                self.formatErrorMessage(
                    expected: expectedEOF,
                    actual: actual
                )
            )
        }
    }

    func testCtrlCharError() {
        let allo = StringParser.string("\tallo\n\r")
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"a\"\n" +
        "expecting \"\\tallo\\n\\r\""

        errorMessageTest(allo, input: "all") { actual in
            XCTAssertEqual(
                expected,
                actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }
    }

    func testPositionError() {
        let spaces = StringParser.spaces
        let allo = StringParser.string("allo")

        let parser = spaces *> allo

        let expectedTab = "\"test\" (line 1, column 9):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""

        errorMessageTest(parser, input: "\tall") { actual in
            XCTAssertEqual(
                expectedTab,
                actual,
                self.formatErrorMessage(
                    expected: expectedTab,
                    actual: actual
                )
            )
        }

        let expectedSpaces = "\"test\" (line 1, column 5):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""

        errorMessageTest(parser, input: "    all") { actual in
            XCTAssertEqual(
                expectedSpaces,
                actual,
                self.formatErrorMessage(
                    expected: expectedSpaces,
                    actual: actual
                )
            )
        }

        let expectedLine = "\"test\" (line 3, column 1):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""

        errorMessageTest(parser, input: "\n\nall") { actual in
            XCTAssertEqual(
                expectedLine,
                actual,
                self.formatErrorMessage(
                    expected: expectedLine,
                    actual: actual
                )
            )
        }
    }

    func testNoOccurenceError() {
        let spaces = StringParser.spaces
        let allo = StringParser.string("allo")
        let parser = spaces *> allo.noOccurence

        let expected = "\"test\" (line 3, column 5):\n" +
        "unexpected \"allo\""

        errorMessageTest(parser, input: "\n\nallo") { actual in
            XCTAssertEqual(
                expected,
                actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }
    }

    func testLabelError() {
        let newline = StringParser.newLine
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting lf new-line"

        errorMessageTest(newline, input: "z") { actual in
            XCTAssertEqual(
                expected,
                actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }
    }

    func testMultiLabelError() {
        let newline = StringParser.newLine.labels("a", "b", "c")
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting a, b or c"

        errorMessageTest(newline, input: "z") { actual in
            XCTAssertEqual(
                expected,
                actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }

        let charA = StringParser.character("a").labels()
        let emptyExpected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\""

        errorMessageTest(charA, input: "z") { actual in
            XCTAssert(
                emptyExpected == actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }
    }

    func testGenericError() {
        let fail = StringParser.fail("I always fail")
        let expected = "\"test\" (line 1, column 1):\n" +
        "I always fail"

        errorMessageTest(fail, input: "") { actual in
            XCTAssertEqual(
                expected,
                actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }
    }

    func testUnknownError() {
        let empty = StringParser.empty
        let expected = "\"test\" (line 1, column 1):\n" +
        "unknown parse error"

        errorMessageTest(empty, input: "z") { actual in
            XCTAssertEqual(
                expected,
                actual,
                self.formatErrorMessage(
                    expected: expected,
                    actual: actual
                )
            )
        }
    }

    func errorMessageTest<Result>(
        _ parser: GenericParser<String, (), Result>,
        input: String,
        assert: (String) -> Void
    ) {
        do {
            try _ = parser.run(sourceName: "test", input: input)
        } catch let error {
            let errorStr = String(describing: error)
            assert(errorStr)
        }
    }

    func formatErrorMessage(expected: String, actual: String) -> String {
        return "Error messages error, " +
            "Expected:\n\(expected)\nActual:\n\(actual)"
    }
}

extension ErrorMessageTests {
    static var allTests: [(String, (ErrorMessageTests) -> () throws -> Void)] {
        return [
            ("testCharacterError", testCharacterError),
            ("testStringError", testStringError),
            ("testEofError", testEofError),
            ("testChoiceError", testChoiceError),
            ("testCtrlCharError", testCtrlCharError),
            ("testPositionError", testPositionError),
            ("testNoOccurenceError", testNoOccurenceError),
            ("testLabelError", testLabelError),
            ("testMultiLabelError", testMultiLabelError),
            ("testGenericError", testGenericError),
            ("testUnknownError", testUnknownError)
        ]
    }
}
