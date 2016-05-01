//
//  Expression.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-10-23.
//  Copyright © 2015 David Dufresne. All rights reserved.
//
//  A helper module to parse "expressions". Builds a parser given a table of operators and associativities.

import Foundation

/// This enumeration specifies the associativity of operators: right, left or none.
public enum Associativity {
    
    case Right, Left, None
    
}

/// This data type specifies operators that work on values of type `Result`. An operator is either binary infix or unary prefix or postfix. A binary operator has also an associated associativity.
public enum Operator<Stream: StreamType, UserState, Result> {
    
    /// Infix operator and associativity.
    case Infix(GenericParser<Stream, UserState, (Result, Result) -> Result>, Associativity)
    
    /// Prefix operator.
    case Prefix(GenericParser<Stream, UserState, Result -> Result>)
    
    /// Postfix operator.
    case Postfix(GenericParser<Stream, UserState, Result -> Result>)
    
}

public struct OperatorTable<Stream: StreamType, UserState, Result>: RangeReplaceableCollectionType, ArrayLiteralConvertible {
    
    /// Represents a valid position in the operator table.
    public typealias Index = Int
    
    /// Operator table's generator.
    public typealias Generator = IndexingGenerator<OperatorTable>
    
    /// Element type of the operator table.
    public typealias Element = [Operator<Stream, UserState, Result>]
    
    /// The position of the first element.
    public let startIndex = 0
    
    /// The operator table's "past the end" position.
    public var endIndex: Int { return table.count }
    
    // Backing store.
    private var table: [Element]
    
    /// Create an instance initialized with elements.
    ///
    /// - parameter arrayLiteral: Arrays of `Operator`.
    public init(arrayLiteral elements: Element...) {
        
        table = elements
        
    }
    
    /// Create an empty instance.
    public init() { table = [] }
    
    /// Build an expression parser for terms returned by `combined` with operators from `self`, taking the associativity and precedence specified in `self` into account. Prefix and postfix operators of the same precedence can only occur once (i.e. `--2` is not allowed if `-` is prefix negate). Prefix and postfix operators of the same precedence associate to the left (i.e. if `++` is postfix increment, than `-2++` equals `-1`, not `-3`).
    ///
    /// It takes care of all the complexity involved in building expression parser. Here is an example of an expression parser that handles prefix signs, postfix increment and basic arithmetic:
    ///
    ///     func binary(name: String, function: (Int, Int) -> Int, assoc: Associativity) -> Operator<String, (), Int> {
    ///
    ///         let opParser = StringParser.string(name) *> GenericParser(result: function)
    ///             return .Infix(opParser, assoc)
    ///
    ///     }
    ///
    ///     func prefix(name: String, function: Int -> Int) -> Operator<String, (), Int> {
    ///
    ///         let opParser = StringParser.string(name) *> GenericParser(result: function)
    ///             return .Prefix(opParser)
    ///
    ///     }
    ///
    ///     func postfix(name: String, function: Int -> Int) -> Operator<String, (), Int> {
    ///
    ///         let opParser = StringParser.string(name) *> GenericParser(result: function)
    ///             return .Postfix(opParser.attempt)
    ///
    ///     }
    ///
    ///     let opTable: OperatorTable<String, (), Int> = [
    ///
    ///         [
    ///             prefix("-", function: -),
    ///             prefix("+", function: { $0 })
    ///         ],
    ///         [
    ///             binary("^", function: power, assoc: .Right)
    ///         ],
    ///         [
    ///             binary("*", function: *, assoc: .Left),
    ///             binary("/", function: /, assoc: .Left)
    ///         ],
    ///         [
    ///             binary("+", function: +, assoc: .Left),
    ///             binary("-", function: -, assoc: .Left)
    ///         ]
    ///
    ///     ]
    ///
    ///     let openingParen = StringParser.character("(")
    ///     let closingParen = StringParser.character(")")
    ///     let decimal = GenericTokenParser<()>.decimal
    ///
    ///     let expression = opTable.expressionParser { expression in
    ///
    ///         expression.between(openingParen, closingParen) <|>
    ///             decimal <?> "simple expression"
    ///
    ///     } <?> "expression"
    ///
    /// - parameter combine: A function receiving a 'simple expression' as parameter that can be nested in other expressions.
    /// - returns: An expression parser for terms returned by `combined` with operators from `self`.
    /// - SeeAlso: GenericParser.recursive(combine: GenericParser -> GenericParser) -> GenericParser
    public func expressionParser(@noescape combine: GenericParser<Stream, UserState, Result> -> GenericParser<Stream, UserState, Result>) -> GenericParser<Stream, UserState, Result> {
        
        var term: GenericParser<Stream, UserState, Result>!
        let lazyTerm = GenericParser<Stream, UserState, Result> { term }
        
        let expr = reduce(lazyTerm) { buildParser($0, operators: $1) }
        term = combine(expr)
        
        return expr
        
    }
    
    private typealias InfixOperatorParser = GenericParser<Stream, UserState, (Result, Result) -> Result>
    private typealias PrefixOperatorParser = GenericParser<Stream, UserState, Result -> Result>
    private typealias PostfixOperatorParser = GenericParser<Stream, UserState, Result -> Result>
    
    private typealias OperatorsTuple = (right: [InfixOperatorParser], left: [InfixOperatorParser], none: [InfixOperatorParser], prefix: [PrefixOperatorParser], postfix: [PostfixOperatorParser])
    
    private func buildParser(term: GenericParser<Stream, UserState, Result>, operators: [Operator<Stream, UserState, Result>]) -> GenericParser<Stream, UserState, Result> {
        
        let ops: OperatorsTuple = operators.reduce(([], [], [], [], []), combine: splitOperators)
        
        let rightAssocOp = GenericParser.choice(ops.right)
        let leftAssocOp = GenericParser.choice(ops.left)
        let nonAssocOp = GenericParser.choice(ops.none)
        let prefixOp = GenericParser.choice(ops.prefix)
        let postfixOp = GenericParser.choice(ops.postfix)
        
        let rightAssocMsg = NSLocalizedString("right", comment: "Right-associative parser.")
        let ambigiousRight = ambigious(rightAssocOp, assoc: rightAssocMsg)
        
        let leftAssocMsg = NSLocalizedString("left", comment: "Left-associative parser.")
        let ambigiousLeft = ambigious(leftAssocOp, assoc: leftAssocMsg)
        
        let nonAssocMsg = NSLocalizedString("non", comment: "Non-associative parser.")
        let ambigiousNon = ambigious(rightAssocOp, assoc: nonAssocMsg)
        
        let prefixParser = prefixOp <|> GenericParser(result: { $0 })
        let postfixParser = postfixOp <|> GenericParser(result: { $0 })
        
        let termParser = prefixParser >>- { pre in
            
            term >>- { t in
                
                postfixParser >>- { post in
                    
                    GenericParser(result: post(pre(t)))
                    
                }
                
            }
            
        }
        
        func rightAssocParser(left: Result) -> GenericParser<Stream, UserState, Result> {
            
            let rightTerm = termParser >>- { rightAssocParser1($0) }
            
            let apply = rightAssocOp >>- { f in
                
                rightTerm >>- { right in GenericParser(result: f(left, right)) }
                
            }
            
            return apply <|> ambigiousLeft <|> ambigiousNon
            
        }
        
        func rightAssocParser1(right: Result) -> GenericParser<Stream, UserState, Result> {
            
            return rightAssocParser(right) <|> GenericParser(result: right)
            
        }
        
        func leftAssocParser(left: Result) -> GenericParser<Stream, UserState, Result> {
            
            let apply = leftAssocOp >>- { f in
                
                termParser >>- { right in
                    
                    leftAssocParser1(f(left, right))
                
                }
                
            }
            
            return apply <|> ambigiousRight <|> ambigiousNon
                
        }
        
        func leftAssocParser1(right: Result) -> GenericParser<Stream, UserState, Result> {
            
            return leftAssocParser(right) <|> GenericParser(result: right)
            
        }
        
        func nonAssocParser(left: Result) -> GenericParser<Stream, UserState, Result> {
            
            return nonAssocOp >>- { f in
                
                termParser >>- { right in
                    
                    ambigiousRight <|> ambigiousLeft <|> ambigiousNon <|>
                        GenericParser(result: f(left, right))
                    
                }
                
            }
            
        }
        
        return termParser >>- { t in
            
            rightAssocParser(t) <|> leftAssocParser(t) <|> nonAssocParser(t) <|>
                GenericParser(result: t) <?> NSLocalizedString("operator", comment: "Expression parser label.")
            
        }
        
    }
    
    private func splitOperators(operators: OperatorsTuple, op: Operator<Stream, UserState, Result>) -> OperatorsTuple {
        
        var ops = operators
        
        switch op {
            
        case .Infix(let parser, let assoc):
            
            switch assoc {
                
            case .None:
                
                var n = ops.none
                n.append(parser)
                
                ops.none = n
                
            case .Left:
                
                var l = ops.left
                l.append(parser)
                
                ops.left = l
                
            case .Right:
                
                var r = ops.right
                r.append(parser)
                
                ops.right = r
                
            }
            
        case .Prefix(let parser):
            
            var pre = ops.prefix
            pre.append(parser)
            
            ops.prefix = pre
            
        case .Postfix(let parser):
            
            var post = ops.postfix
            post.append(parser)
            
            ops.postfix = post
            
        }
        
        return ops
        
    }
    
    private func ambigious(op: InfixOperatorParser, assoc: String) -> GenericParser<Stream, UserState, Result> {
        
        let msg = NSLocalizedString("ambiguous use of a %@ associative operator", comment: "Expression parser.")
        let localizedMsg = String(format: msg, arguments: [assoc])
        
        return (op *> GenericParser.fail(localizedMsg)).attempt
        
    }
    
    /// Replace the given subRange of elements with newElements.
    ///
    /// - parameters:
    ///   - subRange: Range of elements to replace.
    ///   - newElements: New elements replacing the previous elements contained in `subRange`.
    public mutating func replaceRange<C: CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Index>, with newElements: C) {
        
        table.replaceRange(subRange, with: newElements)
        
    }
    
    public subscript(position: Index) -> Element { return table[position] }
    
}
