//
//  TestUtilities.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-21.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

/// Run `parser` in a `do-catch` block on the supplied input strings. If the `satisfy` function returns `false`, `errorMessage` is reported using `XCTFail()`. If an error is thrown it is reported with `XCTFail()`.
func testStringParserSuccess<Result, Input: CollectionType where Input.Generator.Element == String>(parser: GenericParser<String, (), Result>, inputs: Input, errorMessage: String, satisfy: (String, Result) -> Bool) {
    
    do {
        
        for input in inputs {
            
            let result = try parser.run(sourceName: "", input: input)
            
            if !satisfy(input, result) {
                
                XCTFail(errorMessage + "\nInput: " + input + "\nResult: " + String(result))
            
            }
            
        }
        
    } catch let parseError as ParseError {
        
        XCTFail(String(parseError))
        
    } catch let error {
        
        XCTFail(String(error))
        
    }
    
}

/// Run `parser` in a `do-catch` block. If the `satisfy` function returns `false`, `errorMessage` is reported using `XCTFail()`. If an error is thrown it is reported with `XCTFail()`.
func testParserSuccess<Result>(parser: GenericParser<String, (), Result>, errorMessage: String, satisfy: (String, Result) -> Bool) {
    
    testStringParserSuccess(parser, inputs: [""], errorMessage: errorMessage, satisfy: satisfy)
    
}

/// Run `parser` in a `do-catch` block on the supplied input strings. If `parser` succeeds, `errorMessage` is reported using `XCTFail()`. If an error is thrown it is reported with `XCTFail()`.
func testStringParserFailure<Result, Input: CollectionType where Input.Generator.Element == String>(parser: GenericParser<String, (), Result>, inputs: Input, errorMessage: String) {
    
    for input in inputs {
        
        do {
            
            let result = try parser.run(sourceName: "", input: input)
            XCTFail(errorMessage + "\nInput: " + input + "\nResult: " + String(result))
            
        } catch is ParseError {
            
            // Parser failed as expected.
            
        } catch let error {
            
            XCTFail(String(error))
            
        }
        
    }
    
}
