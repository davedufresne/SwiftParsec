//
//  ExpressionTests.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-10-30.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

class ExpressionTests: XCTestCase {
    
    func testExpr() {
        
        let power: (Int, Int) -> Int = { base, exp in
            
            Int(pow(Double(base), Double(exp)))
        
        }
        
        let opTable: OperatorTable<String, (), Int> = [
            
            [
                prefix("-", function: -),
                prefix("+", function: { $0 })
            ],
            [
                postfix("++", function: { (var num) in num++ })
            ],
            [
                binary(">>", function: >>, assoc: .None),
                binary("<<", function: <<, assoc: .None)
            ],
            [
                binary("^", function: power, assoc: .Right)
            ],
            [
                binary("*", function: *, assoc: .Left),
                binary("/", function: /, assoc: .Left)
            ],
            [
                binary("+", function: +, assoc: .Left),
                binary("-", function: -, assoc: .Left)
            ]
        
        ]
        
        let openingParen = StringParser.character("(")
        let closingParen = StringParser.character(")")
        let decimal = GenericTokenParser<()>.decimal
        
        let expr = opTable.expressionParser { expr in
            
            expr.between(openingParen, closingParen) <|> decimal
            
        }
        
        let matching = ["1+2*4-8+((3-12)/8)+(-71)+2^2^3", "+3-(3++)+5", "4>>2", "4<<2"]
        var expected = [1+2*4-8+((3-12)/8)+(-71)+power(2, power(2, 3))]
        
        var three = 3
        expected.append(+3-(three++)+5)
        
        expected.append(4>>2)
        expected.append(4<<2)
        
        var index = 0
        
        let errorMessage = "OperatorTable.expressionParser did not succeed."
        
        testStringParserSuccess(expr, inputs: matching, errorMessage: errorMessage) { _, result in
            
            result == expected[index++]
            
        }
        
    }
    
    func binary(name: String, function: (Int, Int) -> Int, assoc: Associativity) -> Operator<String, (), Int> {
        
        let opParser = StringParser.string(name) *> GenericParser(result: function)
        return .Infix(opParser, assoc)
        
    }
    
    func prefix(name: String, function: Int -> Int) -> Operator<String, (), Int> {
        
        let opParser = StringParser.string(name) *> GenericParser(result: function)
        return .Prefix(opParser)
        
    }
    
    func postfix(name: String, function: Int -> Int) -> Operator<String, (), Int> {
        
        let opParser = StringParser.string(name) *> GenericParser(result: function)
        return .Postfix(opParser.attempt)
        
    }
    
}
