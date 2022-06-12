// ==============================================================================
// CharacterParsersTests.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-09-17.
// Copyright © 2015 David Dufresne. All rights reserved.
// ==============================================================================
// swiftlint:disable type_body_length

import XCTest
@testable import SwiftParsec

class CharacterParsersTests: XCTestCase {
    func testOneOf() {
        let vowel = StringParser.oneOf("aeiou")

        // Test for success.
        let matching = ["axyz", "exyz", "ixyz", "oxyz", "uxyz"]
        let errorMessage = "GenericParser.oneOf should succeed."

        testStringParserSuccess(vowel, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
            XCTAssert(
                isMatch,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test for failure.
        let notMatching = ["xyzu", "yzo", "zi", "taeiou", "vexyz"]
        let shouldFailMessage = "GenericParser.oneOf should fail."

        testStringParserFailure(vowel, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testOneOfInterval() {
        let interval = StringParser.oneOf("a"..."z")

        // Test for success.
        let matching = ["axyz", "exyz", "ixyz", "oxyz", "uxyz"]
        let errorMessage = "GenericParser.oneOf should succeed."

        testStringParserSuccess(interval, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
            XCTAssert(
                isMatch,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test for failure.
        let notMatching = ["1xyzu", "?yzo", "Ezi", ")taeiou", "@vexyz"]
        let shouldFailMessage = "GenericParser.oneOf should fail."

        testStringParserFailure(interval, inputs: notMatching) { input, result in
            XCTFail(self.formatErrorMessage(
                shouldFailMessage,
                input: input,
                result: result
                )
            )
        }
    }

    func testNoneOf() {
        let consonant = StringParser.noneOf("aeiou")

        // Test for success.
        let matching = ["xayz", "reyz", "fiyz", "doyz", "cuyz"]
        let errorMessage = "GenericParser.noneOf should succeed."

        testStringParserSuccess(consonant, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
            XCTAssert(
                isMatch,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test for failure.
        let notMatching = ["axyz", "exyz", "ixyz", "oxyz", "uxyz"]
        let shouldFailMessage = "GenericParser.noneOf should fail."

        testStringParserFailure(consonant, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testSpaces() {
        let suffix = "xadf"
        let skipSpaces = StringParser.spaces *>
            StringParser.character(suffix[suffix.startIndex])

        // Test for success.
        let matching = ["  \n  \t \r \r\n" + suffix]
        let errorMessage = "GenericParser.spaces should succeed."

        testStringParserSuccess(skipSpaces, inputs: matching) { input, result in
            let isMatch = suffix.hasPrefix(String(result))
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
        let notMatching = ["axyz", "exyz", "ixyz", "oxyz", "uxyz"]
        let shouldFailMessage = "GenericParser.spaces should fail."

        testStringParserFailure(skipSpaces, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testUnicodeSpace() {
        let space = StringParser.unicodeSpace

        // Test for success.
        let matching = [
            " xadf", "\tljk", "\n;k", "\r;kl", "\r\nadf", "\u{000C}jkl",
            "\u{000B}gjh", "\u{0085}jg", "\u{00A0}gj", "\u{1680}", "\u{180E}",
            "\u{2000}", "\u{2001}", "\u{2002}", "\u{2003}", "\u{2004}",
            "\u{2005}", "\u{2006}", "\u{2007}", "\u{2008}", "\u{2009}",
            "\u{200A}", "\u{200B}fhd", "\u{2028}", "\u{2029}", "\u{202F}ghfd",
            "\u{205F}gh", "\u{3000}hjg", "\u{FEFF}kgh"
        ]
        let errorMessage = "GenericParser.unicodeSpace should succeed."

        testStringParserSuccess(space, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = ["axyz   "]
        let shouldFailMessage = "GenericParser.unicodeSpace should fail."

        testStringParserFailure(space, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testSpace() {
        let space = StringParser.space

        // Test for success.
        let matching = [
            " xadf", "\tljk", "\n;k", "\r;kl", "\r\nadf", "\u{000C}jkl",
            "\u{000B}gjh"
        ]
        let errorMessage = "GenericParser.space should succeed."

        testStringParserSuccess(space, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = ["axyz   "]
        let shouldFailMessage = "GenericParser.space should fail."

        testStringParserFailure(space, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testNewLine() {
        let newLine = StringParser.newLine

        // Test for success.
        let matching = ["\n"]
        let errorMessage = "GenericParser.newLine should succeed."

        testStringParserSuccess(newLine, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = ["axyz\n"]
        let shouldFailMessage = "GenericParser.newLine should fail."

        testStringParserFailure(newLine, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testCrlf() {
        let newLine = StringParser.crlf

        // Test for success.
        // "\r\n" is combined in one Unicode Scalar.
        let matching = ["\r\n", "\u{000D}\u{000A}"]
        let errorMessage = "GenericParser.crlf should succeed."

        testStringParserSuccess(newLine, inputs: matching) { input, result in
            XCTAssertEqual(
                "\n",
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = ["\n", "\r", "\n\r", "adsf\r\n"]
        let shouldFailMessage = "GenericParser.crlf should fail."

        testStringParserFailure(newLine, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testEndOfLine() {
        let endOfLine = StringParser.endOfLine

        // Test for success.
        // "\r\n" is combined in one Unicode Scalar.
        let matching = ["\r\n", "\u{000D}\u{000A}", "\n"]
        let errorMessage = "GenericParser.endOfLine should succeed."

        testStringParserSuccess(endOfLine, inputs: matching) { input, result in
            XCTAssertEqual(
                "\n",
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = ["\r", "ddsdf\n\r", "adsf\r\n", "adsf'\n"]
        let shouldFailMessage = "GenericParser.endOfLine should fail."

        testStringParserFailure(endOfLine, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testTab() {
        let tab = StringParser.tab

        // Test for success.
        let matching = ["\t"]
        let errorMessage = "GenericParser.tab should succeed."

        testStringParserSuccess(tab, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = ["axyz\t"]
        let shouldFailMessage = "GenericParser.tab should fail."

        testStringParserFailure(tab, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testUppercase() {
        let uppercase = StringParser.uppercase

        // Test for success.
        let matching = ["Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff"]
        let errorMessage = "GenericParser.uppercase should succeed."

        testStringParserSuccess(uppercase, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            "easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf", ";", ":", ","
        ]
        let shouldFailMessage = "GenericParser.uppercase should fail."

        testStringParserFailure(uppercase, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testLowercase() {
        let lowercase = StringParser.lowercase

        // Test for success.
        let matching = ["easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf"]
        let errorMessage = "GenericParser.lowercase should succeed."

        testStringParserSuccess(lowercase, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            "Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff", ";", ":", ","
        ]
        let shouldFailMessage = "GenericParser.lowercase should fail."

        testStringParserFailure(lowercase, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testAlphaNumeric() {
        let alphaNum = StringParser.alphaNumeric

        // Test for success.
        let matching = [
            "easdf", "a", "à", "ç", "é", "\u{65}\u{301}", "è", "ê", "ùasdf",
            "Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff", "1", "2", "3",
            "4", "5", "6", "7", "8", "9", "0"
        ]
        let errorMessage = "GenericParser.alphaNumeric should succeed."

        testStringParserSuccess(alphaNum, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            ";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±",
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}",
            "{", "<", ">", "?", "\u{E9}\u{20DD}"
        ]
        let shouldFailMessage = "GenericParser.alphaNumeric should fail."

        testStringParserFailure(alphaNum, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testLetter() {
        let letter = StringParser.letter

        // Test for success.
        let matching = [
            "easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf", "Ezcxv", "A", "À",
            "Ç", "É", "È", "Ë", "Ê", "Ùaff"
        ]
        let errorMessage = "GenericParser.letter should succeed."

        testStringParserSuccess(letter, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            ";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±",
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}",
            "{", "<", ">", "?", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
        ]
        let shouldFailMessage = "GenericParser.letter should fail."

        testStringParserFailure(letter, inputs: notMatching) { input, result in
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
        let symbol = StringParser.symbol

        // Test for success.
        let matching = ["+", "÷", "±", "$", "√"]
        let errorMessage = "GenericParser.symbol should succeed."

        testStringParserSuccess(symbol, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            "easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf", "Ezcxv", "A", "À",
            "Ç", "É", "È", "Ë", "Ê", "Ùaff", "1", "2", "3", "4", "5", "6", "7",
            "8", "9", "0"
        ]
        let shouldFailMessage = "GenericParser.letter should fail."

        testStringParserFailure(symbol, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testDigit() {
        let digit = StringParser.digit

        // Test for success.
        let matching = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let errorMessage = "GenericParser.digit should succeed."

        testStringParserSuccess(digit, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            ";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±",
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}",
            "{", "<", ">", "?", "easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf",
            "Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff"
        ]
        let shouldFailMessage = "GenericParser.digit should fail."

        testStringParserFailure(digit, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testDecimalDigit() {
        let hexDigit = StringParser.decimalDigit

        // Test for success.
        let matching = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let errorMessage = "GenericParser.decimalDigit should succeed."

        testStringParserSuccess(hexDigit, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            ";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±",
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}",
            "{", "<", ">", "?", "à", "ç", "é", "è", "ê", "ùasdf", "À", "Ç", "É",
            "È", "Ë", "Ê", "Ùaff", "a", "b", "c", "d", "e", "f", "A", "B", "C",
            "D", "E", "F"
        ]
        let shouldFailMessage = "GenericParser.decimalDigit should fail."

        testStringParserFailure(hexDigit, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testHexadecimalDigit() {
        let hexDigit = StringParser.hexadecimalDigit

        // Test for success.
        let matching = [
            "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "a", "b", "c",
            "d", "e", "f", "A", "B", "C", "D", "E", "F"
        ]
        let errorMessage = "GenericParser.hexadecimalDigit should succeed."

        testStringParserSuccess(hexDigit, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            ";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±",
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}",
            "{", "<", ">", "?", "à", "ç", "é", "è", "ê", "ùasdf", "À", "Ç", "É",
            "È", "Ë", "Ê", "Ùaff"
        ]

        let shouldFailMessage =
        "GenericParser.hexadecimalDigit should fail."

        testStringParserFailure(hexDigit, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testOctalDigit() {
        let octDigit = StringParser.octalDigit

        // Test for success.
        let matching = ["1", "2", "3", "4", "5", "6", "7", "0"]
        let errorMessage = "GenericParser.octalDigit should succeed."

        testStringParserSuccess(octDigit, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(String(result))
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
        let notMatching = [
            ";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±",
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}",
            "{", "<", ">", "?", "à", "ç", "é", "è", "ê", "ùasdf", "À", "Ç", "É",
            "È", "Ë", "Ê", "Ùaff", "8", "9"
        ]
        let shouldFailMessage = "GenericParser.octalDigit should fail."

        testStringParserFailure(octDigit, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testString() {
        let stringToMatch = "aàeéèëcçAÀEÉÈËCÇ"
        let string1 = StringParser.string(stringToMatch)

        // Test for success.
        let matching = [stringToMatch + "qewr", stringToMatch]
        let errorMessage = "GenericParser.string should succeed."

        testStringParserSuccess(string1, inputs: matching) { input, result in
            let isMatch = input.hasPrefix(result)
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
        let notMatching = [
            "àaeéèëcçAÀEÉÈËCÇ",
            String(stringToMatch.dropLast())
        ]
        let shouldFailMessage = "GenericParser.string should fail."

        testStringParserFailure(string1, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test for success with empty string to match.
        let string2 = StringParser.string("")
        testStringParserSuccess(string2, inputs: ["", "adsf"]) { input, result in
            XCTAssert(
                result.isEmpty,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }
}

extension CharacterParsersTests {
    static var allTests: [(String, (CharacterParsersTests) -> () throws -> Void)] {
        return [
            ("testOneOf", testOneOf),
            ("testOneOfInterval", testOneOfInterval),
            ("testNoneOf", testNoneOf),
            ("testSpaces", testSpaces),
            ("testUnicodeSpace", testUnicodeSpace),
            ("testSpace", testSpace),
            ("testNewLine", testNewLine),
            ("testCrlf", testCrlf),
            ("testEndOfLine", testEndOfLine),
            ("testTab", testTab),
            ("testUppercase", testUppercase),
            ("testLowercase", testLowercase),
            ("testAlphaNumeric", testAlphaNumeric),
            ("testLetter", testLetter),
            ("testSymbol", testSymbol),
            ("testDigit", testDigit),
            ("testDecimalDigit", testDecimalDigit),
            ("testHexadecimalDigit", testHexadecimalDigit),
            ("testOctalDigit", testOctalDigit),
            ("testString", testString)
        ]
    }
}
