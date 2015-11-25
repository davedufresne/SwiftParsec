//
//  PermutationTests.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-11-05.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

class PermutationTests: XCTestCase {
    
    func testPermutation() {
        
        let permutation: Permutation = [
            
            (StringParser.character("a"), nil),
            (StringParser.character("b"), nil),
            (StringParser.character("c"), nil)
            
        ]
        
        let parser = permutation.parser.stringValue
        
        // Test for success.
        let matching = ["abc", "acb", "bac", "bca", "cab", "cba"]
        let errorMessage = "Permutation.parser did not succeed."
        
        testStringParserSuccess(parser, inputs: matching, errorMessage: errorMessage) { _, result in
            
            result == "abc"
            
        }
        
        // Test for failure.
        let notMatching = ["bc", "cb", "ac", "ca", "ab", "ba", "aaa", "aab", "aac", "bbb", "bba", "bbc", "ccc", "cca", "ccb"]
        let shouldFailMessage = "Permutation.parser should have failed."
        
        testStringParserFailure(parser, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testPermutationWithSeparator() {
        
        let permutation: Permutation = [
            
            (StringParser.character("a"), nil),
            (StringParser.character("b"), nil),
            (StringParser.character("c"), nil),
            
        ]
        
        let separator = StringParser.character(",")
        let parser = permutation.parserWithSeparator(separator).stringValue
        
        // Test for success.
        let matching = ["a,b,c", "a,c,b", "b,a,c", "b,c,a", "c,a,b", "c,b,a"]
        let errorMessage = "Permutation.parserWithSeparator did not succeed."
        
        testStringParserSuccess(parser, inputs: matching, errorMessage: errorMessage) { _, result in
            
            result == "abc"
            
        }
        
        // Test for failure.
        let notMatching = ["ab,c", "a,cb", ",b,a,c", "bca"]
        let shouldFailMessage = "Permutation.parserWithSeparator should have failed."
        
        testStringParserFailure(parser, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testPermutationWithOptional() {
        
        let permutation: Permutation = [
            
            (StringParser.character("a"), "_"),
            (StringParser.character("b"), nil),
            (StringParser.character("c"), "?")
            
        ]
        
        let parser = permutation.parser.stringValue
        
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
        
        let errorMessage = "Permutation.parser did not succeed."
        
        for (matching, expected) in [test1, test2, test3] {
            
            testStringParserSuccess(parser, inputs: matching, errorMessage: errorMessage) { _, result in
                
                result == expected
                
            }
            
        }
        
        // Test for failure.
        let notMatching = ["ac", "ca", "zbc"]
        let shouldFailMessage = "Permutation.parser should have failed."
        
        testStringParserFailure(parser, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testPermutationWithSeparatorAndOptional() {
        
        let permutation: Permutation = [
            
            (StringParser.character("a"), nil),
            (StringParser.character("b"), "_"),
            (StringParser.character("c"), nil),
            (StringParser.character("d"), nil),
            
        ]
        
        let separator = StringParser.character(",")
        let parser = permutation.parserWithSeparator(separator).stringValue
        
        // Test for success.
        let matching1 = ["a,b,c,d", "a,c,b,d", "b,a,c,d", "b,c,a,d", "c,a,b,d", "c,b,a,d"]
        let expected1 = "abcd"
        let test1 = (matching1, expected1)
        
        let matching2 = ["a,c,d", "a,d,c", "c,a,d", "c,d,a", "d,a,c", "d,c,a"]
        let expected2 = "a_cd"
        let test2 = (matching2, expected2)
        
        let errorMessage = "Permutation.parser did not succeed."
        
        for (matching, expected) in [test1, test2] {
            
            testStringParserSuccess(parser, inputs: matching, errorMessage: errorMessage) { _, result in
                
                result == expected
                
            }
            
        }
        
        // Test for failure.
        let notMatching = ["abcd", "acd", "ab,c,d", "abd", "cda", "dad"]
        let shouldFailMessage = "Permutation.parser should have failed."
        
        testStringParserFailure(parser, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
    func testPermutationWithNil() {
        
        let lexer = GenericTokenParser<()>(languageDefinition: LanguageDefinition.empty)
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
        
        let imgAttrs = permutation.parser
        
        let img = symbol("img") *> imgAttrs <* symbol("/")
        let imgTag = lexer.angles(img)
        
        // Test for success.
        let matching = [
            
            "<img  src=\"test.jpg\" alt=\"A test image\" />",
            "<img longdesc=\"A long description\"  src=\"test.jpg\" alt=\"A test image\" />",
            "<img width=\"12\" src=\"test.jpg\"  alt=\"A test image\"/>",
            "<img src=\"test.jpg\" height=\"120\" alt=\"A test image\"   />",
            "<img height=\"120\" src=\"test.jpg\" alt=\"A test image\" width=\"12\" / >",
            "<img src=\"test.jpg\" width=\"12\" longdesc=\"A long description\" alt=\"A test image\" height=\"120\" />"
            
        ]
        
        let expected: [[String?]] = [
            
            ["test.jpg", "A test image", nil, nil, nil],
            ["test.jpg", "A test image", "A long description", nil, nil],
            ["test.jpg", "A test image", nil, nil, "12"],
            ["test.jpg", "A test image", nil, "120", nil],
            ["test.jpg", "A test image", nil, "120", "12"],
            ["test.jpg", "A test image", "A long description", "120", "12"],
        
        ]
        
        let errorMessage = "Permutation.parser did not succeed."
        
        var index = 0
        testStringParserSuccess(imgTag, inputs: matching, errorMessage: errorMessage) { _, result in
            
            result == expected[index++]
            
        }
        
        // Test for failure.
        let notMatching = ["<imgwidth=\"12\" longdesc=\"A long description\" alt=\"A test image\" height=\"120\" />"]
        let shouldFailMessage = "Permutation.parser should have failed."
        
        testStringParserFailure(imgTag, inputs: notMatching, errorMessage: shouldFailMessage)
        
    }
    
}

private func ==(lhs: [String?], rhs: [String?]) -> Bool {
    
    return lhs.count == rhs.count && !zip(lhs, rhs).contains { $0 != $1 }
    
}
