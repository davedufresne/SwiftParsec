// ==============================================================================
// DefaultTokenParserTests.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-10-14.
// Copyright © 2015 David Dufresne. All rights reserved.
// ==============================================================================
// swiftlint:disable function_body_length file_length type_body_length

import XCTest
@testable import SwiftParsec

class GenericTokenParserTests: XCTestCase {
    func testIdentifier() {
        //
        // Case sensitive
        //
        do {
            let swift = LanguageDefinition<()>.swift
            let swiftIdentifier =
                GenericTokenParser(languageDefinition: swift).identifier

            let empty = LanguageDefinition<()>.empty
            let identifier =
                GenericTokenParser(languageDefinition: empty).identifier

            // Test for success.
            let swiftMatching = [
                "test", "breakTest", "classTest", "t", "Break", "Class", "$0",
                "$1"
            ]
            let matching = [
                "test", "breakTest", "classTest", "t", "Break", "Class"
            ]

            let parsersAssociation = [
                (swiftIdentifier, swiftMatching), (identifier, matching)
            ]

            let errorMessage = "GenericTokenParser.identifier should succeed."

            for (parser, inputs) in parsersAssociation {
                testStringParserSuccess(parser, inputs: inputs) { input, result in
                    XCTAssertEqual(
                        input,
                        result,
                        self.formatErrorMessage(
                            errorMessage,
                            input: input,
                            result: result
                        )
                    )
                }
            }

            // Test when not matching.
            let notMatching = swift.reservedNames

            let shouldFailMessage =
                "GenericTokenParser.identifier should fail."

            testStringParserFailure(swiftIdentifier, inputs: notMatching) { input, result in
                XCTFail(
                    self.formatErrorMessage(
                        shouldFailMessage,
                        input: input,
                        result: result
                    )
                )
            }
        }

        //
        // Not case sensitive
        //
        do {
            var swift = LanguageDefinition<()>.swift
            swift.isCaseSensitive = false

            let identifier =
                GenericTokenParser(languageDefinition: swift).identifier

            // Test for success.
            let matching = [
                "test", "breakTest", "classTest", "BreakTest", "ClassTest", "t"
            ]

            let errorMessage =
                "GenericTokenParser.identifier should succeed."

            testStringParserSuccess(identifier, inputs: matching) { input, result in
                XCTAssertEqual(
                    input,
                    result,
                    self.formatErrorMessage(
                        errorMessage,
                        input: input,
                        result: result
                    )
                )
            }

            // Test when not matching.
            let notMatchingLower = swift.reservedNames
            let notMatching = notMatchingLower +
                notMatchingLower.map { $0.uppercased() }

            let shouldFailMessage =
                "GenericTokenParser.identifier should fail."

            testStringParserFailure(identifier, inputs: notMatching) { input, result in
                XCTFail(
                    self.formatErrorMessage(
                        shouldFailMessage,
                        input: input,
                        result: result
                    )
                )
            }
        }
    }

    func testReservedName() {
        var swift = LanguageDefinition<()>.swift
        let reservedName =
            GenericTokenParser(languageDefinition: swift).reservedName

        swift.isCaseSensitive = false
        let reservedCaseInsensitive =
            GenericTokenParser(languageDefinition: swift).reservedName

        // Test for success.
        let matching = swift.reservedNames
        let uppercaseMatching = swift.reservedNames.map { $0.uppercased() }

        let reservedNames = matching.map { reservedName($0) }
        let reservedUppercaseNames =
            uppercaseMatching.map { reservedCaseInsensitive($0) }

        let matchingAssociation = zip(reservedNames, matching)
        let uppercaseMatchingAssociation =
            zip(reservedUppercaseNames, uppercaseMatching)

        for assocArray in [matchingAssociation, uppercaseMatchingAssociation] {
            for (parser, input) in assocArray {
                testStringParserSuccess(parser, inputs: [input]) { _, _ in }
            }
        }

        // Test when not matching.
        let notMatching = matching.map { $0 + "Test" }
        let notMatchingAssociation = zip(reservedNames, notMatching)
        let shouldFailMessage =
            "GenericTokenParser.reservedName should fail."

        for (parser, noMatch) in notMatchingAssociation {
            testStringParserFailure(parser, inputs: [noMatch]) { input, result in
                XCTFail(
                    self.formatErrorMessage(
                        shouldFailMessage,
                        input: input,
                        result: result
                    )
                )
            }
        }
    }

    func testLegalOperator() {
        let swift = LanguageDefinition<()>.swift
        let legalOperator =
            GenericTokenParser(languageDefinition: swift).legalOperator

        // Test for success.
        let matching = [
            "/>", "=>", "-<", "+", "!>", "*", "%>", "<>", "><", "&>", "|>",
            "^>", "?>", "~>"
        ]

        let errorMessage = "GenericTokenParser.legalOperator should succeed."

        testStringParserSuccess(legalOperator, inputs: matching) {input, result in
            XCTAssertEqual(
                input,
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = swift.reservedOperators
        let shouldFailMessage =
            "GenericTokenParser.legalOperator should fail."

        testStringParserFailure(legalOperator, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testReservedOperator() {
        let swift = LanguageDefinition<()>.swift
        let reservedOperator =
            GenericTokenParser(languageDefinition: swift).reservedOperator

        // Test for success.
        let matching = swift.reservedOperators

        let reservedOperators = matching.map { reservedOperator($0) }
        let matchingAssociation = zip(reservedOperators, matching)

        for (parser, match) in matchingAssociation {
            testStringParserSuccess(parser, inputs: [match]) { _, _ in }
        }

        // Test when not matching.
        let notMatching = matching.map { $0 + ">" }
        let notMatchingAssociation = zip(reservedOperators, notMatching)

        let shouldFailMessage =
            "GenericTokenParser.reservedOperator should fail."

        for (parser, noMatch) in notMatchingAssociation {
            testStringParserFailure(parser, inputs: [noMatch]) { input, result in
                XCTFail(
                    self.formatErrorMessage(
                        shouldFailMessage,
                        input: input,
                        result: result
                    )
                )
            }
        }
    }

    func testCharacterLiteral() {
        let java = LanguageDefinition<()>.javaStyle
        let characterLiteral =
            GenericTokenParser(languageDefinition: java).characterLiteral

        // Test for success.
        let matching = [
            "'a'", "'\\97'", "'\\x61'", "'\\o141'", "'\\n'", "'\\CR'", "'\\^@'",
            "'\\^A'"
        ]
        let expected: [Character] = [
            "a", "a", "a", "a", "\n", "\r", "\0", "\u{0001}"
        ]
        var index = 0

        let errorMessage =
            "GenericTokenParser.characterLiteral should succeed."

        testStringParserSuccess(characterLiteral, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "'a", "'\\97", "'\\x61", "'\\o141", "'\\x'", "'\\ZZ'", "'\\^a'",
            "'\\'", "'\\xFFFFFFFFFFFFFFF'"
        ]

        let shouldFailMessage =
            "GenericTokenParser.characterLiteral should fail."

        testStringParserFailure(characterLiteral, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testStringLiteral() {
        let java = LanguageDefinition<()>.javaStyle
        let stringLiteral =
            GenericTokenParser(languageDefinition: java).stringLiteral

        // Test for success.
        let matching = [
            "\"a\"", "\"\\97\"", "\"\\x61\"", "\"\\o141\"", "\"\\n\"",
            "\"\\CR\"", "\"\\^@\"", "\"abc\\n\\x61\"", "\"\\130\\&11\"",
            "\"foo\\&bar\"",
            "\"this is a \\\n\\long string,\\\n\\ spanning multiple lines\""
        ]
        let expected = [
            "a", "a", "a", "a", "\n", "\r", "\0", "abc\na", "\u{82}11",
            "foobar", "this is a long string, spanning multiple lines"
        ]
        var index = 0

        let errorMessage =
            "GenericTokenParser.stringLiteral should succeed."

        testStringParserSuccess(stringLiteral, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "'a", "'\\97", "'\\x61", "'\\o141", "'\\x'", "'\\ZZ'", "'\\^a'",
            "'\\'"
        ]

        let shouldFailMessage =
            "GenericTokenParser.stringLiteral should fail."

        testStringParserFailure(stringLiteral, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testSwiftStringLiteral() {
        let swift = LanguageDefinition<()>.swift
        let stringLiteral =
            GenericTokenParser(languageDefinition: swift).stringLiteral

        // Test for success.
        let matching = [
            "\"a\"", "\"\\u{61}\"", "\"\\0\"", "\"\\\\\"", "\"\\t\"", "\"\\n\"",
            "\"\\r\"", "\"\\\"\"", "\"\\\'\"", "\"abc\\n\\u{61}\""
        ]
        let expected = [
            "a", "a", "\0", "\\", "\t", "\n", "\r", "\"", "\'", "abc\na"
        ]
        var index = 0

        let errorMessage = "GenericTokenParser.stringLiteral should succeed."

        testStringParserSuccess(stringLiteral, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "\"a", "\"\\{61}\"", "\\0\"", "\"\\\"", "\"\\u{123456789}\"",
            "\"\\u{FFFFFFFF}\""
        ]

        let shouldFailMessage =
            "GenericTokenParser.stringLiteral should fail."

        testStringParserFailure(stringLiteral, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testJSONStringLiteral() {
        let json = LanguageDefinition<()>.json
        let stringLiteral =
            GenericTokenParser(languageDefinition: json).stringLiteral

        // Test for success.
        let matching = [
            "\"a\"", "\"\\u0061\"", "\"\\\"\"", "\"\\\\\"", "\"\\/\"",
            "\"\\b\"", "\"\\f\"", "\"\\n\"", "\"\\r\"", "\"\\t\"",
            "\"abc\\n\\u0061\"", "\"\\uD834\\uDD1E\""
        ]
        let expected = [
            "a", "a", "\"", "\\", "/", "\u{0008}", "\u{000C}", "\n", "\r", "\t",
            "abc\na", "\u{1D11E}"
        ]
        var index = 0

        let errorMessage = "GenericTokenParser.stringLiteral should succeed."

        testStringParserSuccess(stringLiteral, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "\"a", "\"\\u061\"", "\"\\61\"", "\\0\"", "\"\\\"", "\"\\u\"",
            "\"\\uD834\"", "\"\\uD834\\u0061\""
        ]

        let shouldFailMessage =
            "GenericTokenParser.stringLiteral should fail."

        testStringParserFailure(stringLiteral, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testNatural() {
        let java = LanguageDefinition<()>.javaStyle
        let natural = GenericTokenParser(languageDefinition: java).natural

        // Test for success.
        let matching = [
            "1", "1234", "0xf", "0xF", "0xffff", "0xFFFF", "0o1", "0o1234", "0"]

        let expected = [1, 1234, 0xF, 0xF, 0xFFFF, 0xFFFF, 0o1, 0o1234, 0]
        var index = 0

        let errorMessage = "GenericTokenParser.natural should succeed."

        testStringParserSuccess(natural, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "-1", "-1234", "-0xf", "+0xF", "-0xffff", "+0xFFFF", "-0o1",
            "-0o1234"
        ]

        let shouldFailMessage =
            "GenericTokenParser.natural should fail."

        testStringParserFailure(natural, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testInteger() {
        let java = LanguageDefinition<()>.javaStyle
        let integer = GenericTokenParser(languageDefinition: java).integer

        // Test for success.
        let matching = [
            "1", "1234", "0xf", "0xF", "0xffff", "0xFFFF", "0o1", "0o1234", "0",
            "-1", "-1234", "-0xf", "+0xF", "-0xffff", "+0xFFFF", "-0o1",
            "-0o1234", "-0"
        ]
        let expected = [
            1, 1234, 0xF, 0xF, 0xffff, 0xFFFF, 0o1, 0o1234, 0, -1, -1234, -0xF,
            0xF, -0xffff, 0xFFFF, -0o1, -0o1234, -0
        ]
        var index = 0

        let errorMessage = "GenericTokenParser.integer should succeed."

        testStringParserSuccess(integer, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "xf", "xF", "ffff", "FFFF", "o1", "o1234", "-xf", "+xF", "-ffff",
            "+FFFF", "-o1", "+o1234"
        ]

        let shouldFailMessage = "GenericTokenParser.integer should fail."

        testStringParserFailure(integer, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testIntegerAsFloat() {
        let java = LanguageDefinition<()>.javaStyle
        let integer =
            GenericTokenParser(languageDefinition: java).integerAsFloat

        // Test for success.
        let matching = [
            "1", "1234", "0xf", "0xF", "0xffff", "0xFFFF", "0o1", "0o1234", "0",
            "-1", "-1234", "-0xf", "+0xF", "-0xffff", "+0xFFFF", "-0o1",
            "-0o1234", "-0"
        ]
        let expected: [Double] = [
            1, 1234, 0xF, 0xF, 0xffff, 0xFFFF, 0o1, 0o1234, 0, -1, -1234, -0xF,
            0xF, -0xffff, 0xFFFF, -0o1, -0o1234, -0
        ]
        var index = 0

        let errorMessage = "GenericTokenParser.integerAsFloat should succeed."

        testStringParserSuccess(integer, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "xf", "xF", "ffff", "FFFF", "o1", "o1234", "-xf", "+xF", "-ffff",
            "+FFFF", "-o1", "+o1234"
        ]

        let shouldFailMessage =
            "GenericTokenParser.integerAsFloat should fail."

        testStringParserFailure(integer, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testFloat() {
        let java = LanguageDefinition<()>.javaStyle
        let float = GenericTokenParser(languageDefinition: java).float

        // Test for success.
        let matching = [
            "1.0", "1234.0", "0.0", "-1.0", "-1234.0", "-0.0", "1234e5",
            "1.234E5", "1.234e-5", "1234E-5", "-1234e5", "-1.234E5",
            "-1.234e-5", "-1234e-5"
        ]
        let expected: [Double] = [
            1.0, 1234.0, 0.0, -1.0, -1234.0, -0.0, 1234e5, 1.234E5, 1.234e-5,
            1234E-5, -1234e5, -1.234E5, -1.234e-5, -1234e-5
        ]
        var index = 0

        let errorMessage = "GenericTokenParser.float should succeed."

        testStringParserSuccess(float, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "1", "1234", "0", "-1", "-1234", "-0", "xf", "xF", "ffff", "FFFF",
            "o1", "o1234", "-xf", "+xF", "-ffff", "+FFFF", "-o1", "+o1234"
        ]

        let shouldFailMessage = "GenericTokenParser.float should fail."

        testStringParserFailure(float, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testNumber() {
        let java = LanguageDefinition<()>.javaStyle
        let number = GenericTokenParser(languageDefinition: java).number

        // Test for success.
        let matching = [
            "1", "1234", "0xf", "0xF", "0xffff", "0xFFFF", "0o1", "0o1234", "0",
            "-1", "-1234", "-0xf", "+0xF", "-0xffff", "+0xFFFF", "-0o1",
            "-0o1234", "-0", "1.0", "1234.0", "0.0", "-1.0", "-1234.0", "-0.0",
            "1234e5", "1.234E5", "1.234e-5", "1234E-5", "-1234e5", "-1.234E5",
            "-1.234e-5", "-1234e-5"
        ]
        let expected: [Either<Int, Double>] = [
            .left(1), .left(1234), .left(0xF), .left(0xF), .left(0xffff),
            .left(0xFFFF), .left(0o1), .left(0o1234), .left(0), .left(-1),
            .left(-1234), .left(-0xF), .left(0xF), .left(-0xffff),
            .left(0xFFFF), .left(-0o1), .left(-0o1234), .left(-0), .right(1.0),
            .right(1234.0), .right(0.0), .right(-1.0), .right(-1234.0),
            .right(-0.0), .right(1234e5), .right(1.234E5), .right(1.234e-5),
            .right(1234E-5), .right(-1234e5), .right(-1.234E5),
            .right(-1.234e-5), .right(-1234e-5)
        ]
        var index = 0

        let errorMessage = "GenericTokenParser.number should succeed."

        testStringParserSuccess(number, inputs: matching) { input, result in
            let expect = expected[index]
            index += 1

            switch result {
            case .left(let intRes):

                if case .left(let val) = expect, intRes == val {
                    return
                }

            case .right(let doubleRes):

                if case .right(let val) = expect, doubleRes == val {
                    return
                }
            }

            XCTFail(
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "xf", "xF", "ffff", "FFFF", "o1", "o1234", "-xf", "+xF", "-ffff",
            "+FFFF", "-o1", "+o1234"
        ]
        let shouldFailMessage = "GenericTokenParser.number should fail."

        testStringParserFailure(number, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testDecimal() {
        let decimal = GenericTokenParser<()>.decimal

        // Test for success.
        let matching = ["1", "1234", "001234"]
        let expected = [1, 1234, 001234]
        var index = 0

        let errorMessage = "GenericTokenParser.decimal should succeed."

        testStringParserSuccess(decimal, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "-1", "-1234", "-0xf", "+0xF", "-0xffff", "+0xFFFF",
            "-0o1", "-0o1234", "99999999999999999999999999"
        ]

        let shouldFailMessage = "GenericTokenParser.decimal should fail."

        testStringParserFailure(decimal, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testHexadecimal() {
        let hexadecimal = GenericTokenParser<()>.hexadecimal

        // Test for success.
        let matching = [
            "x1f", "x2F", "x3ffff", "x4FFFF", "xABCDEF", "X12345", "X67890"
        ]
        let expected = [
            0x1f, 0x2F, 0x3ffff, 0x4FFFF, 0xABCDEF, 0x12345, 0x67890
        ]
        var index = 0

        let errorMessage = "GenericTokenParser.hexadecimal should succeed."

        testStringParserSuccess(hexadecimal, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "1", "1234", "001234", "-1", "-1234", "-0xf", "+0xF", "-0xffff",
            "+0xFFFF", "-0o1", "-0o1234", "xFFFFFFFFFFFFFFFFFFFFFFFFFF"
        ]
        let shouldFailMessage =
            "GenericTokenParser.hexadecimal should fail."

        testStringParserFailure(hexadecimal, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testOctal() {
        let octal = GenericTokenParser<()>.octal

        // Test for success.
        let matching = ["o1", "O1234", "o567"]
        let expected = [0o1, 0o1234, 0o567]
        var index = 0

        let errorMessage = "GenericTokenParser.octal should succeed."

        testStringParserSuccess(octal, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "1", "1234", "001234", "-1", "-1234", "-0xf", "+0xF", "-0xffff",
            "+0xFFFF", "-0o1", "-0o1234",
            "o777777777777777777777777777777777777"
        ]

        let shouldFailMessage = "GenericTokenParser.octal should fail."

        testStringParserFailure(octal, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testSymbol() {
        let java = LanguageDefinition<()>.javaStyle
        let symbol = GenericTokenParser(languageDefinition: java).symbol

        // Test for success.
        let names = ["if", "let", "var", "case"]
        let symbols = names.map { symbol($0) }

        let matching = ["if\n\t\r ", "let/* adsfadsfadsfadsf // */",
                        "var// adsfadsfadsf",
                        "case\u{000B}\u{000C}/*/* adsf*/*/"
        ]
        var index = 0

        let errorMessage = "GenericTokenParser.symbol should succeed."

        for (parser, input) in zip(symbols, matching) {
            testStringParserSuccess(parser, inputs: [input]) { input, result in
                defer { index += 1 }
                XCTAssertEqual(
                    names[index],
                    result,
                    self.formatErrorMessage(
                        errorMessage,
                        input: input,
                        result: result
                    )
                )
            }
        }
    }

    func testWhiteSpace() {
        let str = "a"
        let strParser = StringParser.string(str)

        let empty = LanguageDefinition<()>.empty
        let simpleWhiteSpace =
            GenericTokenParser(languageDefinition: empty).whiteSpace

        let removeWhiteSpace = simpleWhiteSpace *> strParser

        let java = LanguageDefinition<()>.javaStyle
        let javaWhiteSpace =
            GenericTokenParser(languageDefinition: java).whiteSpace

        let removeJavaWhiteSpace = javaWhiteSpace *> strParser

        // Test for success.
        let matchingParsers = [removeWhiteSpace, removeJavaWhiteSpace]
        let matching = [
            [
                " " + str, "\t" + str, "\n" + str, "\r" + str, "\r\n" + str,
                "\u{000B}" + str, "\u{000C}" + str
            ],
            [
                "/*\nMulti line\n*/" + str, "// One line\n" + str,
                "/*/* Nested */*/" + str
            ]
        ]

        let errorMessage = "GenericTokenParser.whiteSpace should succeed."

        for (parser, input) in zip(matchingParsers, matching) {
            testStringParserSuccess(parser, inputs: input) { input, result in
                XCTAssertEqual(
                    str,
                    result,
                    self.formatErrorMessage(
                        errorMessage,
                        input: input,
                        result: result
                    )
                )
            }
        }

        // Test when not matching.
        var emptyCommentLine = LanguageDefinition<()>.empty
        emptyCommentLine.commentStart = "/*"
        emptyCommentLine.commentEnd   = "*/"
        let emptyCommentLineWhiteSpace =
            GenericTokenParser(languageDefinition: emptyCommentLine).whiteSpace

        let removeCommentLine = emptyCommentLineWhiteSpace *> strParser

        var emptyMultiLine = LanguageDefinition<()>.empty
        emptyMultiLine.commentLine = "//"
        let emptyMultiLineWhiteSpace =
            GenericTokenParser(languageDefinition: emptyMultiLine).whiteSpace

        let removeMultiLine = emptyMultiLineWhiteSpace *> strParser

        var nonNested = LanguageDefinition<()>.javaStyle
        nonNested.allowNestedComments = false
        let nonNestedWhiteSpace =
            GenericTokenParser(languageDefinition: nonNested).whiteSpace

        let removeNonNested = nonNestedWhiteSpace *> strParser

        let notMatchingParsers = [
            removeWhiteSpace, removeJavaWhiteSpace, removeCommentLine,
            removeMultiLine, removeNonNested
        ]
        let notMatching = [
            [
                "/*\nMulti line\n*/" + str,
                "// One line\n" + str, "/*/* Nested */*/" + str
            ],
            ["/*/* adsf */" + str],
            ["// Line comment\n" + str],
            ["/* Multi line */" + str],
            ["/*/* Nested */*/" + str]
        ]

        let shouldFailMessage =
            "GenericTokenParser.whiteSpace should fail."

        for (parser, input) in zip(notMatchingParsers, notMatching) {
            testStringParserFailure(parser, inputs: input) { input, result in
                XCTFail(
                    self.formatErrorMessage(
                        shouldFailMessage,
                        input: input,
                        result: result
                    )
                )
            }
        }
    }

    func testParentheses() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        testBracketsParser(
            lexer.parentheses,
            parserName: "parentheses",
            opening: "(",
            closing: ")"
        )
    }

    func testBraces() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        testBracketsParser(
            lexer.braces,
            parserName: "braces",
            opening: "{", closing: "}"
        )
    }

    func testAngles() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        testBracketsParser(
            lexer.angles,
            parserName: "angles",
            opening: "<",
            closing: ">"
        )
    }

    func testBrackets() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        testBracketsParser(
            lexer.brackets,
            parserName: "brackets",
            opening: "[",
            closing: "]"
        )
    }

    func testPunctuations() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        let parsers = [lexer.semicolon, lexer.comma, lexer.colon, lexer.dot]
        let matching = [";", ",", ":", "."]
        let errorMessage = "One of the punctuation parsers should succeed."

        for (parser, match) in zip(parsers, matching) {
            testStringParserSuccess(parser, inputs: [match]) { input, result in
                XCTAssertEqual(
                    input,
                    result,
                    self.formatErrorMessage(
                        errorMessage,
                        input: input,
                        result: result
                    )
                )
            }
        }
    }

    func testSemicolonSeparated() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        testPunctuationSeparated(lexer.semicolonSeparated,
            parserName: "semicolonSeparated",
            punctuation: ";",
            allowZeroOccurence: true)
    }

    func testSemicolonSeparated1() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        testPunctuationSeparated(lexer.semicolonSeparated1,
            parserName: "semicolonSeparated1",
            punctuation: ";",
            allowZeroOccurence: false)
    }

    func testCommaSeparated() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        testPunctuationSeparated(lexer.commaSeparated,
            parserName: "commaSeparated",
            punctuation: ",",
            allowZeroOccurence: true)
    }

    func testCommaSeparated1() {
        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)

        testPunctuationSeparated(lexer.commaSeparated1,
            parserName: "commaSeparated1",
            punctuation: ",",
            allowZeroOccurence: false)
    }

    func testBracketsParser(
        _ parser: (
            GenericParser<String, (), String>
        ) -> GenericParser<String, (), String>,
        parserName: String,
        opening: String,
        closing: String
    ) {
        let expected = "abcd"

        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)
        let brackets = parser(lexer.symbol(expected))

        // Test for success.
        let matching = [
            opening + "abcd" + closing,
            opening + " \n\t\rabcd /*  */ " + closing
        ]

        let errorMessage =
            "GenericTokenParser." + parserName + " should succeed."

        testStringParserSuccess(brackets, inputs: matching) { input, result in
            XCTAssertEqual(
                expected,
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = [
            "abcd" + closing, opening + "abcd", " \n\t\rabcd /*  */ " + closing,
            opening + " \n\t\rabcd /*  */ ", opening + closing
        ]
        let shouldFailMessage =
            "GenericTokenParser." + parserName + " should fail."

        testStringParserFailure(brackets, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testPunctuationSeparated(
        _ parser: (
            GenericParser<String, (), String>
        ) -> GenericParser<String, (), [String]>,
        parserName: String, punctuation: String,
        allowZeroOccurence: Bool
    ) {
        let expected = "abcd"

        let java = LanguageDefinition<()>.javaStyle
        let lexer = GenericTokenParser(languageDefinition: java)
        let sepBy = parser(lexer.symbol(expected))

        // Test for success.
        var matching = [
            expected,
            expected + punctuation + "  " + expected + "  " + punctuation +
                "\n\t\r" + expected + " " + punctuation + " /* 11111 */"
                + expected
        ]

        if allowZeroOccurence { matching.append("") }

        let errorMessage =
            "GenericTokenParser." + parserName + " should succeed."

        testStringParserSuccess(sepBy, inputs: matching) { input, result in
            let isMatch = result.reduce(true) { $0 ? $1 == expected : false }
            XCTAssert(
                isMatch,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        var notMatching = [expected + punctuation]
        if !allowZeroOccurence { notMatching.append("") }

        let shouldFailMessage =
            "GenericTokenParser." + parserName + " should fail."

        testStringParserFailure(sepBy, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }
}

extension GenericTokenParserTests {
    static var allTests: [(String, (GenericTokenParserTests) -> () throws -> Void)] {
        return [
            ("testIdentifier", testIdentifier),
            ("testReservedName", testReservedName),
            ("testLegalOperator", testLegalOperator),
            ("testReservedOperator", testReservedOperator),
            ("testCharacterLiteral", testCharacterLiteral),
            ("testStringLiteral", testStringLiteral),
            ("testSwiftStringLiteral", testSwiftStringLiteral),
            ("testJSONStringLiteral", testJSONStringLiteral),
            ("testNatural", testNatural),
            ("testInteger", testInteger),
            ("testIntegerAsFloat", testIntegerAsFloat),
            ("testFloat", testFloat),
            ("testNumber", testNumber),
            ("testDecimal", testDecimal),
            ("testHexadecimal", testHexadecimal),
            ("testOctal", testOctal),
            ("testSymbol", testSymbol),
            ("testWhiteSpace", testWhiteSpace),
            ("testParentheses", testParentheses),
            ("testBraces", testBraces),
            ("testAngles", testAngles),
            ("testBrackets", testBrackets),
            ("testPunctuations", testPunctuations),
            ("testSemicolonSeparated", testSemicolonSeparated),
            ("testSemicolonSeparated1", testSemicolonSeparated1),
            ("testCommaSeparated", testCommaSeparated),
            ("testCommaSeparated1", testCommaSeparated1)
        ]
    }
}
