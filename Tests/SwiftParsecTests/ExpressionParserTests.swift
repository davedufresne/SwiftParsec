// ==============================================================================
// ExpressionParserTests.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-10-30.
// Copyright © 2015 David Dufresne. All rights reserved.
// ==============================================================================

import XCTest
import func Foundation.pow
@testable import SwiftParsec

class ExpressionParserTests: XCTestCase {
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
                postfix("²", function: { $0 * $0 })
            ],
            [
                binary(">>", function: >>, assoc: .none),
                binary("<<", function: <<, assoc: .none)
            ],
            [
                binary("^", function: power, assoc: .right)
            ],
            [
                binary("*", function: *, assoc: .left),
                binary("/", function: /, assoc: .left)
            ],
            [
                binary("+", function: +, assoc: .left),
                binary("-", function: -, assoc: .left)
            ]
        ]

        let openingParen = StringParser.character("(")
        let closingParen = StringParser.character(")")
        let decimal = GenericTokenParser<()>.decimal

        let expr = opTable.makeExpressionParser { expr in
            expr.between(openingParen, closingParen) <|> decimal
        }

        let matching = [
            "1+2*4-8+((3-12)/8)+(-71)+2^2^3", "(+3-3)+5", "3²", "4>>2", "4<<2"
        ]

        var expected = [1 + 2 * 4 - 8 + ((3 - 12) / 8) + (-71) + power(2, power(2, 3))]
        expected.append((+3 - 3) + 5)
        expected.append(3 * 3)
        expected.append(4 >> 2)
        expected.append(4 << 2)

        var index = 0

        let errorMessage = "OperatorTable.expressionParser should succeed."

        testStringParserSuccess(expr, inputs: matching) { input, result in
            defer { index += 1 }
            XCTAssertEqual(
                expected[index],
                result,
                self.formatErrorMessage(
                    errorMessage,
                    input: input,
                    result: result
                )
            )
        }
    }

    func testReplaceRange() {
        var opTable = OperatorTable<String, (), Int>()

        opTable.append([
            prefix("-", function: -),
            prefix("+", function: { $0 })
        ])

        opTable.append([
            binary("*", function: *, assoc: .left),
            binary("/", function: /, assoc: .left)
        ])

        XCTAssertEqual(opTable.count, 2)

        opTable.replaceSubrange(0..<1, with: [])

        XCTAssertEqual(opTable.count, 1)
    }

    func binary(
        _ name: String,
        function: @escaping (Int, Int) -> Int,
        assoc: Associativity
    ) -> Operator<String, (), Int> {
        let opParser = StringParser.string(name) *>
            GenericParser(result: function)
        return .infix(opParser, assoc)
    }

    func prefix(
        _ name: String,
        function: @escaping (Int) -> Int
    ) -> Operator<String, (), Int> {
        let opParser = StringParser.string(name) *>
            GenericParser(result: function)
        return .prefix(opParser)
    }

    func postfix(
        _ name: String,
        function: @escaping (Int) -> Int
    ) -> Operator<String, (), Int> {
        let opParser = StringParser.string(name) *>
            GenericParser(result: function)
        return .postfix(opParser.attempt)
    }
}

extension ExpressionParserTests {
    static var allTests: [(String, (ExpressionParserTests) -> () throws -> Void)] {
        return [
            ("testExpr", testExpr),
            ("testReplaceRange", testReplaceRange)
        ]
    }
}
