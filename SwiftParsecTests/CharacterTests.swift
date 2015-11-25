//
//  CharacterTests.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-17.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

class CharacterTests: XCTestCase {
    
    func testOneOf() {
        
        let vowel = StringParser.oneOf("aeiou")
        
        // Test for success.
        let matching = ["axyz", "exyz", "ixyz", "oxyz", "uxyz"]
        let errorMessage = "GenericParser.oneOf did not succeed."
        
        testStringParserSuccess(vowel, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test for failure.
        let notMatching = ["xyzu", "yzo", "zi", "taeiou", "vexyz"]
        let shouldFailMessage = "GenericParser.oneOf should have failed."
        
        testStringParserFailure(vowel, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testNoneOf() {
        
        let consonant = StringParser.noneOf("aeiou")
        
        // Test for success.
        let matching = ["xayz", "reyz", "fiyz", "doyz", "cuyz"]
        let errorMessage = "GenericParser.noneOf did not succeed."
        
        testStringParserSuccess(consonant, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test for failure.
        let notMatching = ["axyz", "exyz", "ixyz", "oxyz", "uxyz"]
        let shouldFailMessage = "GenericParser.noneOf should have failed."
        
        testStringParserFailure(consonant, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testSpaces() {
        
        let suffix = "xadf"
        let skipSpaces = StringParser.spaces *> StringParser.character(suffix[suffix.startIndex])
        
        // Test for success.
        let matching = ["  \n  \t \r \r\n" + suffix]
        let errorMessage = "GenericParser.spaces did not succeed."
        
        testStringParserSuccess(skipSpaces, inputs: matching, errorMessage: errorMessage) { input, result in
            
            suffix.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["axyz", "exyz", "ixyz", "oxyz", "uxyz"]
        let shouldFailMessage = "GenericParser.spaces should have failed."
        
        testStringParserFailure(skipSpaces, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testUnicodeSpace() {
        
        let space = StringParser.unicodeSpace
        
        // Test for success.
        let matching = [" xadf", "\tljk", "\n;k", "\r;kl", "\r\nadf", "\u{000C}jkl", "\u{000B}gjh", "\u{0085}jg", "\u{00A0}gj", "\u{1680}", "\u{180E}", "\u{2000}", "\u{2001}", "\u{2002}", "\u{2003}", "\u{2004}", "\u{2005}", "\u{2006}", "\u{2007}", "\u{2008}", "\u{2009}", "\u{200A}", "\u{200B}fhd", "\u{2028}", "\u{2029}", "\u{202F}ghfd", "\u{205F}gh",  "\u{3000}hjg", "\u{FEFF}kgh"]
        let errorMessage = "GenericParser.unicodeSpace did not succeed."
        
        testStringParserSuccess(space, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["axyz   "]
        let shouldFailMessage = "GenericParser.unicodeSpace should have failed."
        
        testStringParserFailure(space, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testSpace() {
        
        let space = StringParser.space
        
        // Test for success.
        let matching = [" xadf", "\tljk", "\n;k", "\r;kl", "\r\nadf", "\u{000C}jkl", "\u{000B}gjh"]
        let errorMessage = "GenericParser.space did not succeed."
        
        testStringParserSuccess(space, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["axyz   "]
        let shouldFailMessage = "GenericParser.space should have failed."
        
        testStringParserFailure(space, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testNewLine() {
        
        let newLine = StringParser.newLine
        
        // Test for success.
        let matching = ["\n"]
        let errorMessage = "GenericParser.newLine did not succeed."
        
        testStringParserSuccess(newLine, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["axyz\n"]
        let shouldFailMessage = "GenericParser.newLine should have failed."
        
        testStringParserFailure(newLine, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testCrlf() {
        
        let newLine = StringParser.crlf
        
        // Test for success.
        let matching = ["\r\n", "\u{000D}\u{000A}"] // "\r\n" is combined in one Unicode Scalar.
        let errorMessage = "GenericParser.crlf did not succeed."
        
        testStringParserSuccess(newLine, inputs: matching, errorMessage: errorMessage) { input, result in
            
            "\n" == result
            
        }
        
        // Test when not matching.
        let notMatching = ["\n", "\r", "\n\r", "adsf\r\n"]
        let shouldFailMessage = "GenericParser.crlf should have failed."
        
        testStringParserFailure(newLine, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testEndOfLine() {
        
        let endOfLine = StringParser.endOfLine
        
        // Test for success.
        let matching = ["\r\n", "\u{000D}\u{000A}", "\n"] // "\r\n" is combined in one Unicode Scalar.
        let errorMessage = "GenericParser.endOfLine did not succeed."
        
        testStringParserSuccess(endOfLine, inputs: matching, errorMessage: errorMessage) { input, result in
            
            "\n" == result
            
        }
        
        // Test when not matching.
        let notMatching = ["\r", "ddsdf\n\r", "adsf\r\n", "adsf'\n"]
        let shouldFailMessage = "GenericParser.endOfLine should have failed."
        
        testStringParserFailure(endOfLine, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testTab() {
        
        let tab = StringParser.tab
        
        // Test for success.
        let matching = ["\t"]
        let errorMessage = "GenericParser.tab did not succeed."
        
        testStringParserSuccess(tab, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["axyz\t"]
        let shouldFailMessage = "GenericParser.tab should have failed."
        
        testStringParserFailure(tab, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testUppercase() {
        
        let uppercase = StringParser.uppercase
        
        // Test for success.
        let matching = ["Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff"]
        let errorMessage = "GenericParser.uppercase did not succeed."
        
        testStringParserSuccess(uppercase, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf", ";", ":", ","]
        let shouldFailMessage = "GenericParser.uppercase should have failed."
        
        testStringParserFailure(uppercase, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testLowercase() {
        
        let lowercase = StringParser.lowercase
        
        // Test for success.
        let matching = ["easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf"]
        let errorMessage = "GenericParser.lowercase did not succeed."
        
        testStringParserSuccess(lowercase, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff", ";", ":", ","]
        let shouldFailMessage = "GenericParser.lowercase should have failed."
        
        testStringParserFailure(lowercase, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testAlphaNumeric() {
        
        let alphaNum = StringParser.alphaNumeric
        
        // Test for success.
        let matching = ["easdf", "a", "à", "ç", "é", "\u{65}\u{301}", "è", "ê", "ùasdf", "Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let errorMessage = "GenericParser.alphaNumeric did not succeed."
        
        testStringParserSuccess(alphaNum, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = [";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}", "{", "<", ">", "?", "\u{E9}\u{20DD}"]
        let shouldFailMessage = "GenericParser.alphaNumeric should have failed."
        
        testStringParserFailure(alphaNum, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testLetter() {
        
        let letter = StringParser.letter
        
        // Test for success.
        let matching = ["easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf", "Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff"]
        let errorMessage = "GenericParser.letter did not succeed."
        
        testStringParserSuccess(letter, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = [";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}", "{", "<", ">", "?", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let shouldFailMessage = "GenericParser.letter should have failed."
        
        testStringParserFailure(letter, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testSymbol() {
        
        let symbol = StringParser.symbol
        
        // Test for success.
        let matching = ["+", "÷", "±", "$", "√"]
        let errorMessage = "GenericParser.symbol did not succeed."
        
        testStringParserSuccess(symbol, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf", "Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let shouldFailMessage = "GenericParser.letter should have failed."
        
        testStringParserFailure(symbol, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testDigit() {
        
        let digit = StringParser.digit
        
        // Test for success.
        let matching = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let errorMessage = "GenericParser.digit did not succeed."
        
        testStringParserSuccess(digit, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = [";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}", "{", "<", ">", "?", "easdf", "a", "à", "ç", "é", "è", "ê", "ùasdf", "Ezcxv", "A", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff"]
        let shouldFailMessage = "GenericParser.digit should have failed."
        
        testStringParserFailure(digit, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testDecimalDigit() {
        
        let hexDigit = StringParser.decimalDigit
        
        // Test for success.
        let matching = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        let errorMessage = "GenericParser.decimalDigit did not succeed."
        
        testStringParserSuccess(hexDigit, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = [";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}", "{", "<", ">", "?", "à", "ç", "é", "è", "ê", "ùasdf", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff", "a", "b", "c", "d", "e", "f", "A", "B", "C", "D", "E", "F"]
        let shouldFailMessage = "GenericParser.decimalDigit should have failed."
        
        testStringParserFailure(hexDigit, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testHexadecimalDigit() {
        
        let hexDigit = StringParser.hexadecimalDigit
        
        // Test for success.
        let matching = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "a", "b", "c", "d", "e", "f", "A", "B", "C", "D", "E", "F"]
        let errorMessage = "GenericParser.hexadecimalDigit did not succeed."
        
        testStringParserSuccess(hexDigit, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = [";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}", "{", "<", ">", "?", "à", "ç", "é", "è", "ê", "ùasdf", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff"]
        let shouldFailMessage = "GenericParser.hexadecimalDigit should have failed."
        
        testStringParserFailure(hexDigit, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testOctalDigit() {
        
        let octDigit = StringParser.octalDigit
        
        // Test for success.
        let matching = ["1", "2", "3", "4", "5", "6", "7", "0"]
        let errorMessage = "GenericParser.octalDigit did not succeed."
        
        testStringParserSuccess(octDigit, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = [";", ":", ",", "\t", "\r\n", "\u{000D}\u{000A}", "\n", "+", "±", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "}", "{", "<", ">", "?", "à", "ç", "é", "è", "ê", "ùasdf", "À", "Ç", "É", "È", "Ë", "Ê", "Ùaff", "8", "9"]
        let shouldFailMessage = "GenericParser.octalDigit should have failed."
        
        testStringParserFailure(octDigit, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testString() {
        
        let stringToMatch = "aàeéèëcçAÀEÉÈËCÇ"
        let string1 = StringParser.string(stringToMatch)
        
        // Test for success.
        let matching = [stringToMatch + "qewr", stringToMatch]
        let errorMessage = "GenericParser.string did not succeed."
        
        testStringParserSuccess(string1, inputs: matching, errorMessage: errorMessage) { input, result in
            
            input.hasPrefix(String(result))
            
        }
        
        // Test when not matching.
        let notMatching = ["àaeéèëcçAÀEÉÈËCÇ", stringToMatch.substringToIndex(stringToMatch.endIndex.predecessor())]
        let shouldFailMessage = "GenericParser.string should have failed."
        
        testStringParserFailure(string1, inputs: notMatching, errorMessage: shouldFailMessage)
        
        // Test for success with empty string to match.
        let string2 = StringParser.string("")
        testStringParserSuccess(string2, inputs: ["", "adsf"], errorMessage: errorMessage){ _, result in
            
            result.isEmpty
            
        }
        
    }
    
}
