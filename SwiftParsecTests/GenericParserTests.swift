//
//  SwiftParsecTests.swift
//  SwiftParsecTests
//
//  Created by David Dufresne on 2015-09-04.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

class GenericParserTests: XCTestCase {
    
    func testMap() {
        
        let trans = { (num: Int) in String(num) }
        let int99 = 99
        
        let intParser = GenericParser<String, (), Int>(result: int99)
        let mappedParser = trans <^> intParser
        
        let errorMessage = "GenericParser.map error."
        
        testParserSuccess(mappedParser) { input, result in
            
            XCTAssertEqual(trans(99), result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let int1 = 1
        
        let functorParser = curriedPlus(int1) <^> intParser
        
        testParserSuccess(functorParser) { input, result in
            
            XCTAssertEqual(int99 + int1, result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
    }
    
    func testApplicative() {
        
        let int99 = 99
        let int99Parser = GenericParser<String, (), Int>(result: int99)
        
        let int1 = 1
        let int1Parser = GenericParser<String, (), Int>(result: int1)
        
        let errorMessage = "GenericParser.apply error."
        
        let applyParser = curriedPlus <^> int99Parser <*> int1Parser
        testParserSuccess(applyParser) { input, result in
            
            XCTAssertEqual(int99 + int1, result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let rightParser = int99Parser *> int1Parser
        testParserSuccess(rightParser) { input, result in
            
            XCTAssertEqual(int1, result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let leftParser = int99Parser <* int1Parser
        testParserSuccess(leftParser) { input, result in
            
            XCTAssertEqual(int99, result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
    }
    
    func testAlternative() {
        
        let empty = StringParser.empty
        let letter = StringParser.oneOf("abc")
        let alt1 = empty <|> letter
        
        let errorMessage = "GenericParser.alternative error."
        
        testStringParserSuccess(alt1, inputs: ["adsf"]) { input, result in
            
            let isMatch = input.hasPrefix(String(result))
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        let string1 = StringParser.string("xads")
        let string2 = StringParser.string("asdfg")
        let alt2 = string1 <|> string2
        
        let matching = ["asdfg, asdfg123"]
        
        testStringParserSuccess(alt2, inputs: matching) { input, result in
            
            let isMatch = input.hasPrefix(result)
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
    }
    
    func testFlatMap() {
        
        let letterDigit = StringParser.oneOf("abc") >>- { letter in
            
            StringParser.digit >>- { digit in
                
                return GenericParser(result: String(letter) + String(digit))
                
            }
            
        }
        
        let matching = ["a1", "b0", "c9"]
        let errorMessage = "GenericParser.flatMap error."
        
        testStringParserSuccess(letterDigit, inputs: matching) { input, result in
            
            XCTAssertEqual(input, result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
    }
    
    func testAtempt() {
        
        let string1 = StringParser.string("asdx")
        let string2 = StringParser.string("asdfg")
        let attempt = string1.attempt <|> string2
        
        let matching = ["asdfg", "asdfg123"]
        let errorMessage = "GenericParser.attempt error."
        
        testStringParserSuccess(attempt, inputs: matching) { input, result in
            
            let isMatch = input.hasPrefix(result)
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
    }
    
    func testLookAhead() {
        
        let longestMatch = "asdfg"
        
        let string1 = StringParser.string("asd")
        let string2 = StringParser.string(longestMatch)
        let lookAhead = string1.lookAhead *> string2
        
        let matching = [longestMatch, longestMatch + "123"]
        let errorMessage = "GenericParser.lookAhead error."
        
        testStringParserSuccess(lookAhead, inputs: matching) { input, result in
            
            XCTAssertEqual(longestMatch, result, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["sad", "das", "asdasdfg"]
        let shouldFailMessage = "GenericParser.lookAhead should have failed."
        
        testStringParserFailure(lookAhead, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testNotAhead() {

        let sample = "asdfg"

        let string1 = StringParser.string("asc")
        let string2 = String.init <^> StringParser.anyCharacter.many
        let notAhead = string1.notAhead *> string2

        // Test when not ahead.
        let notMatching = ["asdfg"]
        let shouldFailMessage = "GenericParser.notAhead should have failed."

        testStringParserSuccess(notAhead, inputs: notMatching) { input, result in
            XCTAssertEqual(sample, result, self.formatErrorMessage(shouldFailMessage, input: input, result: result))
        }

        let matching = ["ascasdfg", "asc"]
        let errorMessage = "GenericParser.notAhead error."
        testStringParserFailure(notAhead, inputs: matching) { input, result in
            XCTFail(self.formatErrorMessage(errorMessage, input: input, result: result))

        }


    }


    func testMany() {
        
        let manyString = StringParser.string("asdf").many
        let matching = ["asdfasdf", "asdfasdfasdf", "asdfasdfasdfasdf", "xasdf"]
        let errorMessage = "GenericParser.many error."
        
        testStringParserSuccess(manyString, inputs: matching) { input, result in
            
            let isMatch = result.isEmpty || input == result.joinWithSeparator("")
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
        // Test when not matching.
        let notMatching = ["asd", "asdfasd"]
        let shouldFailMessage = "GenericParser.many should have failed."
        
        testStringParserFailure(manyString, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testSkipMany() {
        
        let skipManyString = StringParser.string("asdf").skipMany
        
        let matching = ["asdfasdf", "asdfasdfasdf", "asdfasdfasdfasdf", "xasdf"]
        testStringParserSuccess(skipManyString, inputs: matching) { _, _ in true }
        
        // Test when not matching.
        let notMatching = ["asd", "asdfasd"]
        let shouldFailMessage = "GenericParser.skipMany should have failed."
        
        testStringParserFailure(skipManyString, inputs: notMatching) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testEmpty() {
        
        let empty = StringParser.empty
        
        let shouldFailMessage = "GenericParser.empty should have failed."
        
        testStringParserFailure(empty, inputs: [""]) { input, result in
            
            XCTFail(self.formatErrorMessage(shouldFailMessage, input: input, result: result))
            
        }
        
    }
    
    func testLabel() {
        
        let labelStr = "letter x"
        
        let letterx = StringParser.character("x") <?> labelStr
        let letterXx = StringParser.character("x") <|> StringParser.character("X") <?> labelStr
        let input = "a"
        
        for parser in [letterx, letterXx] {
            
            do {
                
                try parser.run(sourceName: "", input: input)
                XCTFail("GenericParser.label should fail.")
                
            } catch let parseError as ParseError {
                
                var containsExpected = false
                var containsSystemUnexpected = false
                
                for msg in parseError.messages {
                    
                    switch msg {
                        
                    case .Expected(let str) where str == labelStr:
                        
                        containsExpected = true
                        
                    case .SystemUnexpected(let str) where str == String(reflecting: input):
                        
                        containsSystemUnexpected = true
                        
                    default: continue
                        
                    }
                    
                }
                
                if !containsExpected || !containsSystemUnexpected {
                    
                    XCTFail("GenericParser.label error.")
                    
                }
                
            } catch let error {
                
                XCTFail(String(error))
                
            }
            
        }
        
    }
    
    func testLift2() {
        
        let leftNumber = 1
        let rightNumber = 2
        
        let left = GenericParser<String, (), Int>(result: leftNumber)
        let right = GenericParser<String, (), Int>(result: rightNumber)
        
        let add = GenericParser.lift2(-, parser1: left, parser2: right)
        
        let errorMessage = "GenericParser.lift2 error."
        testParserSuccess(add) { input, result in
            
            let isMatch = result == leftNumber - rightNumber
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
    }
    
    func testLift3() {
        
        let number1 = 1
        let number2 = 2
        let number3 = 3
        
        let num1 = GenericParser<String, (), Int>(result: number1)
        let num2 = GenericParser<String, (), Int>(result: number2)
        let num3 = GenericParser<String, (), Int>(result: number3)
        
        let add = GenericParser.lift3({ $0 - $1 - $2 }, parser1: num1, parser2: num2, parser3: num3)
        
        let errorMessage = "GenericParser.lift3 error."
        testParserSuccess(add) { input, result in
            
            let isMatch = result == number1 - number2 - number3
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
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
            parser1: num1, parser2: num2, parser3: num3, parser4: num4)
        
        let errorMessage = "GenericParser.lift4 error."
        testParserSuccess(add) { input, result in
            
            let isMatch = result == number1 - number2 - number3 - number4
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
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
            parser1: num1, parser2: num2, parser3: num3, parser4: num4, parser5: num5)
        
        let errorMessage = "GenericParser.lift4 error."
        testParserSuccess(add) { input, result in
            
            let isMatch = result == number1 - number2 - number3 - number4 - number5
            XCTAssert(isMatch, self.formatErrorMessage(errorMessage, input: input, result: result))
            
        }
        
    }
    
    func testUpdateUserState() {
        
        let countLetters = GenericParser<String, Int, Character>.letter <* GenericParser<String, Int, Character>.updateUserState(curriedPlus(1))
        let digits = GenericParser<String, Int, Character>.digit
        let alphaNum = countLetters <* digits.skipMany
        
        let matching = ["a1234H23A3A0à1234É5678ê0ç6ë7"]
        
        let errorMessage = "GenericParser.updateUserState error."
        
        do {
            
            for input in matching {
                
                let (_, state) = try alphaNum.many.run(userState: 0, sourceName: "", input: input)
                
                if state != input.characters.filter({ $0.isAlpha }).count { XCTFail(errorMessage) }
                
            }
            
        } catch let parseError as ParseError {
            
            XCTFail(String(parseError))
            
        } catch let error {
            
            XCTFail(String(error))
            
        }
        
    }
    
    func testParseArray() {
        
        let charArray: [Character] = ["h", "e", "l", "l", "o"]
        let parser = GenericParser<[Character], (), [Character]>.string(charArray)
        
        do {
            
            let result = try parser.run(sourceName: "", input: charArray)
            XCTAssert(result == charArray, "Array parse error.")
            
        } catch let parseError as ParseError {
            
            XCTFail(String(parseError))
            
        } catch let error {
            
            XCTFail(String(error))
            
        }
        
    }
    
}

/// Types implementing the `PlusOperator` protocol have to have an implementation for the `+` operator.
protocol PlusOperator {
    
    func +(lhs: Self, rhs: Self) -> Self
    
}

extension Int: PlusOperator {}
extension Double: PlusOperator {}
extension String: PlusOperator {}

/// Curried version of the `+` operator for `Int`.
func curriedPlus<T: PlusOperator>(lhs: T) -> (T) -> T {
    
    return { rhs in lhs + rhs }
    
}
