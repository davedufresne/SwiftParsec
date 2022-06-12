// ==============================================================================
// GenericParserTests.swift
// SwiftParsecTests
//
// Created by David Dufresne on 2015-09-04.
// Copyright © 2015 David Dufresne. All rights reserved.
// ==============================================================================

import XCTest
@testable import SwiftParsec

class GenericParserTests: XCTestCase {
    func testMap() {
        let trans = { (num: Int) in String(num) }
        let int99 = 99

        let intParser = GenericParser<String, (), Int>(result: int99)
        let mappedParser = trans <^> intParser

        let errorMessage = "GenericParser.map should succeed."

        testParserSuccess(mappedParser) { input, result in
            XCTAssertEqual(
                trans(99),
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        let int1 = 1

        let functorParser = curriedPlus(int1) <^> intParser

        testParserSuccess(functorParser) { input, result in
            XCTAssertEqual(
                int99 + int1,
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testApplicative() {
        let int99 = 99
        let int99Parser = GenericParser<String, (), Int>(result: int99)

        let int1 = 1
        let int1Parser = GenericParser<String, (), Int>(result: int1)

        let errorMessage = "GenericParser.apply should succeed."

        let applyParser = curriedPlus <^> int99Parser <*> int1Parser
        testParserSuccess(applyParser) { input, result in
            XCTAssertEqual(
                int99 + int1,
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        let rightParser = int99Parser *> int1Parser
        testParserSuccess(rightParser) { input, result in
            XCTAssertEqual(
                int1,
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        let leftParser = int99Parser <* int1Parser
        testParserSuccess(leftParser) { input, result in
            XCTAssertEqual(
                int99,
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testAlternative() {
        let empty = StringParser.empty
        let letter = StringParser.oneOf("abc")
        let alt1 = empty <|> letter

        let errorMessage = "GenericParser.alternative should succeed."

        testStringParserSuccess(alt1, inputs: ["adsf"]) { input, result in
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

        let string1 = StringParser.string("xads")
        let string2 = StringParser.string("asdfg")
        let alt2 = string1 <|> string2

        let matching = ["asdfg, asdfg123"]

        testStringParserSuccess(alt2, inputs: matching) { input, result in
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
    }

    func testFlatMap() {
        let letterDigit = StringParser.oneOf("abc") >>- { letter in
            StringParser.digit >>- { digit in
                return GenericParser(result: String(letter) + String(digit))
            }
        }

        let matching = ["a1", "b0", "c9"]
        let errorMessage = "GenericParser.flatMap should succeed."

        testStringParserSuccess(letterDigit, inputs: matching) { input, result in
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

    func testAtempt() {
        let string1 = StringParser.string("asdx")
        let string2 = StringParser.string("asdfg")
        let attempt = string1.attempt <|> string2

        let matching = ["asdfg", "asdfg123"]
        let errorMessage = "GenericParser.attempt should succeed."

        testStringParserSuccess(attempt, inputs: matching) { input, result in
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
    }

    func testLookAhead() {
        let longestMatch = "asdfg"

        let string1 = StringParser.string("asd")
        let string2 = StringParser.string(longestMatch)
        let lookAhead = string1.lookAhead *> string2

        let matching = [longestMatch, longestMatch + "123"]
        let errorMessage = "GenericParser.lookAhead should succeed."

        testStringParserSuccess(lookAhead, inputs: matching) { input, result in
            XCTAssertEqual(
                longestMatch,
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }

        // Test when not matching.
        let notMatching = ["sad", "das", "asdasdfg"]
        let shouldFailMessage = "GenericParser.lookAhead should fail."

        testStringParserFailure(lookAhead, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testMany() {
        let manyString = StringParser.string("asdf").many
        let matching = ["asdfasdf", "asdfasdfasdf", "asdfasdfasdfasdf", "xasdf"]
        let errorMessage = "GenericParser.many should succeed."

        testStringParserSuccess(manyString, inputs: matching) { input, result in
            let isMatch = result.isEmpty ||
                input == result.joined(separator: "")
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
        let notMatching = ["asd", "asdfasd"]
        let shouldFailMessage = "GenericParser.many should fail."

        testStringParserFailure(manyString, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testSkipMany() {
        let skipManyString = StringParser.string("asdf").skipMany

        let matching = ["asdfasdf", "asdfasdfasdf", "asdfasdfasdfasdf", "xasdf"]
        testStringParserSuccess(skipManyString, inputs: matching) { _, _ in }

        // Test when not matching.
        let notMatching = ["asd", "asdfasd"]
        let shouldFailMessage = "GenericParser.skipMany should fail."

        testStringParserFailure(skipManyString, inputs: notMatching) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testEmpty() {
        let empty = StringParser.empty

        let shouldFailMessage = "GenericParser.empty should fail."

        testStringParserFailure(empty, inputs: [""]) { input, result in
            XCTFail(
                self.formatErrorMessage(
                    shouldFailMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testLabel() {
        let labelStr = "letter x"

        let letterx = StringParser.character("x") <?> labelStr
        let letterXx = StringParser.character("x") <|>
            StringParser.character("X") <?> labelStr
        let input = "a"

        for parser in [letterx, letterXx] {
            do {
                try _ = parser.run(sourceName: "", input: input)
                XCTFail("GenericParser.label should fail.")
            } catch let parseError as ParseError {
                var containsExpected = false
                var containsSystemUnexpected = false

                for msg in parseError.messages {
                    switch msg {
                    case .expected(let str) where str == labelStr:

                        containsExpected = true

                    case .systemUnexpected(let str)
                    where str == String(reflecting: input):

                        containsSystemUnexpected = true

                    default: continue
                    }
                }

                if !containsExpected || !containsSystemUnexpected {
                    XCTFail("GenericParser.label should succeed.")
                }
            } catch let error {
                XCTFail(String(describing: error))
            }
        }
    }

    func testLift2() {
        let leftNumber = 1
        let rightNumber = 2

        let left = GenericParser<String, (), Int>(result: leftNumber)
        let right = GenericParser<String, (), Int>(result: rightNumber)

        let add = GenericParser.lift2(-, parser1: left, parser2: right)

        let errorMessage = "GenericParser.lift2 should succeed."
        testParserSuccess(add) { input, result in
            let isMatch = result == leftNumber - rightNumber
            XCTAssert(
                isMatch,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testLift3() {
        let number1 = 1
        let number2 = 2
        let number3 = 3

        let num1 = GenericParser<String, (), Int>(result: number1)
        let num2 = GenericParser<String, (), Int>(result: number2)
        let num3 = GenericParser<String, (), Int>(result: number3)

        let add = GenericParser.lift3({ $0 - $1 - $2 },
            parser1: num1,
            parser2: num2,
            parser3: num3
        )

        let errorMessage = "GenericParser.lift3 should succeed."
        testParserSuccess(add) { input, result in
            let isMatch = result == number1 - number2 - number3
            XCTAssert(
                isMatch,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testLift4() {
        let number1 = 1
        let number2 = 2
        let number3 = 3
        let number4 = 4

        let num1 = GenericParser<String, (), Int>(result: number1)
        let num2 = GenericParser<String, (), Int>(result: number2)
        let num3 = GenericParser<String, (), Int>(result: number3)
        let num4 = GenericParser<String, (), Int>(result: number4)

        let add = GenericParser.lift4({ $0 - $1 - $2 - $3 },
            parser1: num1,
            parser2: num2,
            parser3: num3,
            parser4: num4
        )

        let errorMessage = "GenericParser.lift4 should succeed."
        testParserSuccess(add) { input, result in
            let isMatch = result == number1 - number2 - number3 - number4
            XCTAssert(
                isMatch,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testLift5() {
        let number1 = 1
        let number2 = 2
        let number3 = 3
        let number4 = 4
        let number5 = 5

        let num1 = GenericParser<String, (), Int>(result: number1)
        let num2 = GenericParser<String, (), Int>(result: number2)
        let num3 = GenericParser<String, (), Int>(result: number3)
        let num4 = GenericParser<String, (), Int>(result: number4)
        let num5 = GenericParser<String, (), Int>(result: number5)

        let add = GenericParser.lift5({ $0 - $1 - $2 - $3 - $4 },
            parser1: num1,
            parser2: num2,
            parser3: num3,
            parser4: num4,
            parser5: num5
        )

        let errorMessage = "GenericParser.lift4 should succeed."
        testParserSuccess(add) { input, result in
            let isMatch =
                result == number1 - number2 - number3 - number4 - number5
            XCTAssert(
                isMatch,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testUpdateUserState() {
        let updateUserState =
        GenericParser<String, Int, Character>.updateUserState(curriedPlus(1))

        let countLetters =
            GenericParser<String, Int, Character>.letter <* updateUserState
        let digits = GenericParser<String, Int, Character>.digit
        let alphaNum = countLetters <* digits.skipMany

        let matching = ["a1234H23A3A0à1234É5678ê0ç6ë7"]

        let errorMessage = "GenericParser.updateUserState should succeed."

        let userState = alphaNum.many *>
            GenericParser<String, Int, Int>.userState
        do {
            for input in matching {
                let state = try userState.run(
                    userState: 0,
                    sourceName: "",
                    input: input
                )

                let alphaCharacters = input.filter { $0.isAlpha }
                if state != alphaCharacters.count {
                    XCTFail(errorMessage)
                }
            }
        } catch let parseError as ParseError {
            XCTFail(String(describing: parseError))
        } catch let error {
            XCTFail(String(describing: error))
        }
    }

    func testParseArray() {
        let charArray: [Character] = ["h", "e", "l", "l", "o"]
        let parser = GenericParser<[Character], (), [Character]>.string(
            charArray
        )

        do {
            let result = try parser.run(sourceName: "", input: charArray)
            XCTAssert(result == charArray, "Array parse should succeed.")
        } catch let parseError as ParseError {
            XCTFail(String(describing: parseError))
        } catch let error {
            XCTFail(String(describing: error))
        }
    }
}

/// Types implementing the `PlusOperator` protocol have to have an
/// implementation for the `+` operator.
protocol PlusOperator {
    static func + (lhs: Self, rhs: Self) -> Self
}

extension Int: PlusOperator {}
extension Double: PlusOperator {}
extension String: PlusOperator {}

/// Curried version of the `+` operator for `Int`.
func curriedPlus<T: PlusOperator>(_ lhs: T) -> (T) -> T {
    return { rhs in lhs + rhs }
}

extension GenericParserTests {
    static var allTests: [(String, (GenericParserTests) -> () throws -> Void)] {
        return [
            ("testMap", testMap),
            ("testApplicative", testApplicative),
            ("testAlternative", testAlternative),
            ("testFlatMap", testFlatMap),
            ("testAtempt", testAtempt),
            ("testLookAhead", testLookAhead),
            ("testMany", testMany),
            ("testSkipMany", testSkipMany),
            ("testEmpty", testEmpty),
            ("testLabel", testLabel),
            ("testLift2", testLift2),
            ("testLift3", testLift3),
            ("testLift4", testLift4),
            ("testLift5", testLift5),
            ("testUpdateUserState", testUpdateUserState),
            ("testParseArray", testParseArray)
        ]
    }
}
