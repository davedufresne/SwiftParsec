// ==============================================================================
// PermutationTests.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-11-05.
// Copyright © 2015 David Dufresne. All rights reserved.
// ==============================================================================

import XCTest
@testable import SwiftParsec

class PermutationTests: XCTestCase {
    func testCollectionMethods() {
        var permutation: Permutation = [
            (StringParser.character("a"), nil),
            (StringParser.character("b"), nil),
            (StringParser.character("c"), nil)
        ]

        XCTAssertEqual(
            permutation.count,
            3,
            "Permutation.count should return 3."
        )

        permutation.replaceSubrange(0..<1, with: [])

        XCTAssertEqual(
            permutation.count,
            2,
            "Permutation.replaceRange should remove first element."
        )
    }

    func testPermutation() {
        let permutation: Permutation = [
            (StringParser.character("a"), nil),
            (StringParser.character("b"), nil),
            (StringParser.character("c"), nil)
        ]

        let parser = permutation.makeParser().stringValue

        // Test for success.
        let matching = ["abc", "acb", "bac", "bca", "cab", "cba"]
        let errorMessage = "Permutation.parser should succeed."

        testStringParserSuccess(parser, inputs: matching) { input, result in
            XCTAssertEqual(
                "abc",
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test for failure.
        let notMatching = [
            "bc", "cb", "ac", "ca", "ab", "ba", "aaa", "aab", "aac", "bbb",
            "bba", "bbc", "ccc", "cca", "ccb"
        ]
        let shouldFailMessage = "Permutation.parser should fail."

        testStringParserFailure(parser, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testPermutationWithSeparator() {
        let permutation: Permutation = [
            (StringParser.character("a"), nil),
            (StringParser.character("b"), nil),
            (StringParser.character("c"), nil)
        ]

        let comma = StringParser.character(",")
        let parser = permutation.makeParser(separator: comma).stringValue

        // Test for success.
        let matching = ["a,b,c", "a,c,b", "b,a,c", "b,c,a", "c,a,b", "c,b,a"]
        let errorMessage = "Permutation.parserWithSeparator should succeed."

        testStringParserSuccess(parser, inputs: matching) { input, result in
            XCTAssertEqual(
                "abc",
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test for failure.
        let notMatching = ["ab,c", "a,cb", ",b,a,c", "bca"]
        let shouldFailMessage =
            "Permutation.parserWithSeparator should fail."

        testStringParserFailure(parser, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testPermutationWithOptional() {
        let permutation: Permutation = [
            (StringParser.character("a"), Character("_")),
            (StringParser.character("b"), nil),
            (StringParser.character("c"), Character("?"))
        ]

        let parser = permutation.makeParser().stringValue

        // Test for success.
        let matching1 = ["abc", "acb", "bac", "bca", "cab", "cba"]
        let expected1 = "abc"
        let test1 = (matching1, expected1)

        let matching2 = ["ab", "ba"]
        let expected2 = "ab?"
        let test2 = (matching2, expected2)

        let matching3 = ["bc", "cb"]
        let expected3 = "_bc"
        let test3 = (matching3, expected3)

        let errorMessage = "Permutation.parser should succeed."

        for (matching, expected) in [test1, test2, test3] {
            testStringParserSuccess(parser, inputs: matching) { input, result in
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
        }

        // Test for failure.
        let notMatching = ["ac", "ca", "zbc"]
        let shouldFailMessage = "Permutation.parser should fail."

        testStringParserFailure(parser, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testPermutationWithSeparatorAndOptional() {
        let permutation: Permutation = [
            (StringParser.character("a"), nil),
            (StringParser.character("b"), Character("_")),
            (StringParser.character("c"), nil),
            (StringParser.character("d"), nil)
        ]

        let comma = StringParser.character(",")
        let parser = permutation.makeParser(separator: comma).stringValue

        // Test for success.
        let matching1 = [
            "a,b,c,d", "a,c,b,d", "b,a,c,d", "b,c,a,d", "c,a,b,d", "c,b,a,d"
        ]
        let expected1 = "abcd"
        let test1 = (matching1, expected1)

        let matching2 = ["a,c,d", "a,d,c", "c,a,d", "c,d,a", "d,a,c", "d,c,a"]
        let expected2 = "a_cd"
        let test2 = (matching2, expected2)

        let errorMessage = "Permutation.parser should succeed."

        for (matching, expected) in [test1, test2] {
            testStringParserSuccess(parser, inputs: matching) { input, result in
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
        }

        // Test for failure.
        let notMatching = ["abcd", "acd", "ab,c,d", "abd", "cda", "dad"]
        let shouldFailMessage = "Permutation.parser should fail."

        testStringParserFailure(parser, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testPermutationWithNil() {
        let lexer = GenericTokenParser<()>(
            languageDefinition: LanguageDefinition.empty
        )
        let symbol = lexer.symbol

        let equal = symbol("=")

        let quote = symbol("\"")
        let anyChar = StringParser.anyCharacter.manyTill(quote).stringValue
        let value = quote *> anyChar.optional

        // Required parsers
        let srcAttr = symbol("src") *> equal *> value
        let altAttr = symbol("alt") *> equal *> value

        // Optional parsers
        let longdescAttr = symbol("longdesc") *> equal *> value
        let heightAttr = symbol("height") *> equal *> value
        let widthAttr = symbol("width") *> equal *> value

        var permutation = Permutation<String, (), String?>()
        permutation.appendParser(srcAttr)
        permutation.appendParser(altAttr)
        permutation.appendOptionalParser(longdescAttr, otherwise: nil)
        permutation.appendOptionalParser(heightAttr, otherwise: nil)
        permutation.appendOptionalParser(widthAttr, otherwise: nil)

        let imgAttrs = permutation.makeParser()

        let img = symbol("img") *> imgAttrs <* symbol("/")
        let imgTag = lexer.angles(img)

        // Test for success.
        let matching = [
            "<img  src=\"test.jpg\" alt=\"A test image\" />",
            "<img longdesc=\"A long description\"  src=\"test.jpg\" " +
                "alt=\"A test image\" />",
            "<img width=\"12\" src=\"test.jpg\"  alt=\"A test image\"/>",
            "<img src=\"test.jpg\" height=\"120\" alt=\"A test image\"   />",
            "<img height=\"120\" src=\"test.jpg\" alt=\"A test image\" " +
                "width=\"12\" / >",
            "<img src=\"test.jpg\" width=\"12\" " +
                "longdesc=\"A long description\" alt=\"A test image\" " +
                "height=\"120\" />"
        ]

        let expected: [[String?]] = [
            ["test.jpg", "A test image", nil, nil, nil],
            ["test.jpg", "A test image", "A long description", nil, nil],
            ["test.jpg", "A test image", nil, nil, "12"],
            ["test.jpg", "A test image", nil, "120", nil],
            ["test.jpg", "A test image", nil, "120", "12"],
            ["test.jpg", "A test image", "A long description", "120", "12"]
        ]

        let errorMessage = "Permutation.parser should succeed."

        var index = 0
        testStringParserSuccess(imgTag, inputs: matching) { input, result in
            defer { index += 1 }
            let isMatch = result == expected[index]
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
        let notMatching = [
            "<imgwidth=\"12\" longdesc=\"A long description\" " +
                "alt=\"A test image\" height=\"120\" />"
        ]
        let shouldFailMessage = "Permutation.parser should fail."

        testStringParserFailure(imgTag, inputs: notMatching) { input, result in
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

// ==============================================================================
private func == (lhs: [String?], rhs: [String?]) -> Bool {
    return lhs.count == rhs.count && !zip(lhs, rhs).contains { $0 != $1 }
}

extension PermutationTests {
    static var allTests: [(String, (PermutationTests) -> () throws -> Void)] {
        return [
            ("testCollectionMethods", testCollectionMethods),
            ("testPermutation", testPermutation),
            ("testPermutationWithSeparator", testPermutationWithSeparator),
            ("testPermutationWithOptional", testPermutationWithOptional),
            ("testPermutationWithSeparatorAndOptional",
             testPermutationWithSeparatorAndOptional),
            ("testPermutationWithNil", testPermutationWithNil)
        ]
    }
}
