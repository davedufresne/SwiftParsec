//
//  SwiftParsecTests.swift
//  SwiftParsecTests
//
//  Created by David Dufresne on 2015-09-04.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

class PrimitiveTests: XCTestCase {
    
    func testMap() {
        
        let trans = { (num: Int) in String(num) }
        let int99 = 99
        
        let intParser = GenericParser<String, (), Int>(result: int99)
        let mappedParser = trans <^> intParser
        
        let errorMessage = "GenericParser.map error."
        
        testParserSuccess(mappedParser, errorMessage: errorMessage) { _, result in
            
            result == trans(int99)
            
        }
        
        let int1 = 1
        
        let functorParser = curriedPlus(int1) <^> intParser
        
        testParserSuccess(functorParser, errorMessage: errorMessage) { _, result in
            
            result == int99 + int1
            
        }
        
    }
    
    func testApplicative() {
        
        let int99 = 99
        let int99Parser = GenericParser<String, (), Int>(result: int99)
        
        let int1 = 1
        let int1Parser = GenericParser<String, (), Int>(result: int1)
        
        let errorMessage = "GenericParser.apply error."
        
        let applyParser = curriedPlus <^> int99Parser <*> int1Parser
        testParserSuccess(applyParser, errorMessage: errorMessage) { _, result in
            
            result == int99 + int1
            
        }
        
        let rightParser = int99Parser *> int1Parser
        testParserSuccess(rightParser, errorMessage: errorMessage) { _, result in
            
            result == int1
            
        }
        
        let leftParser = int99Parser <* int1Parser
        testParserSuccess(leftParser, errorMessage: errorMessage) { _, result in
            
            result == int99
            
        }
        
    }
    
    func testAlternative() {
        
        let empty = StringParser.empty
        let letter = StringParser.oneOf("abc")
        let alt1 = empty <|> letter
        
        let errorMessage = "GenericParser.alternative error."
        
        testStringParserSuccess(alt1, inputs: ["adsf"], errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        let string1 = StringParser.string("xads")
        let string2 = StringParser.string("asdfg")
        let alt2 = string1 <|> string2
        
        let matching = ["asdfg, asdfg123"]
        
        testStringParserSuccess(alt2, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(result)
            
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
        
        testStringParserSuccess(letterDigit, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input == result
            
        }
        
    }
    
    func testAtempt() {
        
        let string1 = StringParser.string("asdx")
        let string2 = StringParser.string("asdfg")
        let attempt = string1.attempt <|> string2
        
        let matching = ["asdfg", "asdfg123"]
        let errorMessage = "GenericParser.attempt error."
        
        testStringParserSuccess(attempt, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(result)
            
        }
        
    }
    
    func testLookAhead() {
        
        let longestMatch = "asdfg"
        
        let string1 = StringParser.string("asd")
        let string2 = StringParser.string(longestMatch)
        let lookAhead = string1.lookAhead *> string2
        
        let matching = [longestMatch, longestMatch + "123"]
        let errorMessage = "GenericParser.lookAhead error."
        
        testStringParserSuccess(lookAhead, inputs: matching, errorMessage: errorMessage) { input, result in
            
            longestMatch == result
            
        }
        
        // Test when not matching.
        let notMatching = ["sad", "das", "asdasdfg"]
        let shouldFailMessage = "GenericParser.lookAhead should have failed."
        testStringParserFailure(lookAhead, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testMany() {
        
        let manyString = StringParser.string("asdf").many
        let matching = ["asdfasdf", "asdfasdfasdf", "asdfasdfasdfasdf", "xasdf"]
        let errorMessage = "GenericParser.many error."
        
        testStringParserSuccess(manyString, inputs: matching, errorMessage: errorMessage) { input, result in
            
            result.isEmpty || input == result.joinWithSeparator("")
            
        }
        
        // Test when not matching.
        let notMatching = ["asd", "asdfasd"]
        let shouldFailMessage = "GenericParser.many should have failed."
        testStringParserFailure(manyString, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testSkipMany() {
        
        let skipManyString = StringParser.string("asdf").skipMany
        
        let matching = ["asdfasdf", "asdfasdfasdf", "asdfasdfasdfasdf", "xasdf"]
        let errorMessage = "GenericParser.skipMany error."
        testStringParserSuccess(skipManyString, inputs: matching, errorMessage: errorMessage) { _, _ in true }
        
        // Test when not matching.
        let notMatching = ["asd", "asdfasd"]
        let shouldFailMessage = "GenericParser.skipMany should have failed."
        testStringParserFailure(skipManyString, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testEmpty() {
        
        let empty = StringParser.empty
        
        let shouldFailMessage = "GenericParser.empty should have failed."
        testStringParserFailure(empty, inputs: [""], errorMessage: shouldFailMessage)
        
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
        testParserSuccess(add, errorMessage: errorMessage) { _, result in
            
            result == leftNumber - rightNumber
            
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
        testParserSuccess(add, errorMessage: errorMessage) { _, result in
            
            result == number1 - number2 - number3
            
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
        testParserSuccess(add, errorMessage: errorMessage) { _, result in
            
            result == number1 - number2 - number3 - number4
            
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
        testParserSuccess(add, errorMessage: errorMessage) { _, result in
            
            result == number1 - number2 - number3 - number4 - number5
            
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
func curriedPlus<T: PlusOperator>(lhs: T)(rhs: T) -> T {
    
    return lhs + rhs
    
}
