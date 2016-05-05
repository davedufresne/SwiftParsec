//
//  TestUtilities.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-21.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

extension XCTestCase {
    
    /// Run `parser` in a `do-catch` block on the supplied input strings. The assertions are performed in the `assert` function. If an error is thrown it is reported with `XCTFail()`.
    func testStringParserSuccess<Result, Input: CollectionType where Input.Generator.Element == String>(parser: GenericParser<String, (), Result>, inputs: Input, assert: (String, Result) -> Void) {
        
        do {
            
            for input in inputs {
                
                let result = try parser.run(sourceName: "", input: input)
                
                assert(input, result)
                
            }
            
        } catch let parseError as ParseError {
            
            XCTFail(String(parseError))
            
        } catch let error {
            
            XCTFail(String(error))
            
        }
        
    }
    
    /// Run `parser` in a `do-catch` block. The assertions are performed in the `assert` function. If an error is thrown it is reported with `XCTFail()`.
    func testParserSuccess<Result>(parser: GenericParser<String, (), Result>, assert: (String, Result) -> Void) {
        
        testStringParserSuccess(parser, inputs: [""], assert: assert)
        
    }
    
    /// Run `parser` in a `do-catch` block on the supplied input strings. The assertions are performed in the `assert` function. If an error is thrown it is reported with `XCTFail()`.
    func testStringParserFailure<Result, Input: CollectionType where Input.Generator.Element == String>(parser: GenericParser<String, (), Result>, inputs: Input, assert: (String, Result) -> Void) {
        
        for input in inputs {
            
            do {
                
                let result = try parser.run(sourceName: "", input: input)
                assert(input, result)
                
            } catch is ParseError {
                
                // Parser failed as expected.
                
            } catch let error {
                
                XCTFail(String(error))
                
            }
            
        }
        
    }
    
    func formatErrorMessage<Result>(message: String, input: String, result: Result) -> String {
        
        return message + "\nInput: " + input + "\nResult: " + String(result)
        
    }
    
}
