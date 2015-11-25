//
//  ErrorMessageTest.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-10-28.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

class ErrorMessageTests: XCTestCase {
    
    func testCharacterError() {
        
        let vowel = StringParser.oneOf("aeiou")
        let expectedVowel = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\""
        
        errorMessageTest(vowel, input: "z", expectedMessage: expectedVowel)
        
        let char = StringParser.character("a")
        let expectedChar = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting \"a\""
        
        errorMessageTest(char, input: "z", expectedMessage: expectedChar)
        
    }
    
    func testStringError() {
        
        let allo = StringParser.string("allo")
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting \"allo\""
        
        errorMessageTest(allo, input: "allz", expectedMessage: expected)
        
    }
    
    func testEofError() {
        
        let allo = StringParser.string("allo")
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""
        
        errorMessageTest(allo, input: "all", expectedMessage: expected)
        
    }
    
    func testChoiceError() {
        
        let allo = StringParser.string("allo")
        let hello = StringParser.string("hello")
        let hola = StringParser.string("hola")
        
        let hellos = allo <|> hello <|> hola
        
        let expectedHellos = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting \"allo\", \"hello\" or \"hola\""
        
        errorMessageTest(hellos, input: "z", expectedMessage: expectedHellos)
        
        let expectedEof = "\"test\" (line 1, column 1):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""
        
        errorMessageTest(hellos, input: "all", expectedMessage: expectedEof)
        
    }
    
    func testCtrlCharError() {
        
        let allo = StringParser.string("\tallo\n\r")
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"a\"\n" +
        "expecting \"\\tallo\\n\\r\""
        
        errorMessageTest(allo, input: "all", expectedMessage: expected)
        
    }
    
    func testPositionError() {
        
        let spaces = StringParser.spaces
        let allo = StringParser.string("allo")
        
        let parser = spaces *> allo
        
        let expectedTab = "\"test\" (line 1, column 9):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""
        
        errorMessageTest(parser, input: "\tall", expectedMessage: expectedTab)
        
        let expectedSpaces = "\"test\" (line 1, column 5):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""
        
        errorMessageTest(parser, input: "    all", expectedMessage: expectedSpaces)
        
        let expectedLine = "\"test\" (line 3, column 1):\n" +
        "unexpected end of input\n" +
        "expecting \"allo\""
        
        errorMessageTest(parser, input: "\n\nall", expectedMessage: expectedLine)
        
    }
    
    func testNoOccurenceError() {
        
        let spaces = StringParser.spaces
        let allo = StringParser.string("allo")
        let parser = spaces *> allo.noOccurence
        
        let expected = "\"test\" (line 3, column 5):\n" +
        "unexpected \"allo\""
        
        errorMessageTest(parser, input: "\n\nallo", expectedMessage: expected)
        
    }
    
    func testLabelError() {
        
        let newline = StringParser.newLine
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting lf new-line"
        
        errorMessageTest(newline, input: "z", expectedMessage: expected)
        
    }
    
    func testMultiLabelError() {
        
        let newline = StringParser.newLine.labels("a", "b", "c")
        let expected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\"\n" +
        "expecting a, b or c"
        
        errorMessageTest(newline, input: "z", expectedMessage: expected)
        
        let charA = StringParser.character("a").labels()
        let emptyExpected = "\"test\" (line 1, column 1):\n" +
        "unexpected \"z\""
        
        errorMessageTest(charA, input: "z", expectedMessage: emptyExpected)
        
    }
    
    func errorMessageTest<Result>(parser: GenericParser<String, (), Result>, input: String, expectedMessage: String) {
        
        do {
            
            try parser.run(sourceName: "test", input: input)
            
        } catch let error {
            
            let errorStr = String(error)
            XCTAssert(errorStr == expectedMessage,
                "Error messages error, Expected:\n\(expectedMessage)\nActual:\n\(errorStr)")
            
        }
        
    }
    
}
