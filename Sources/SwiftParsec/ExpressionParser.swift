// ==============================================================================
// Expression.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-10-23.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// A helper module to parse "expressions". Builds a parser given a table of
// operators and associativities.
// ==============================================================================

// ==============================================================================
/// This enumeration specifies the associativity of operators: right, left or
/// none.
public enum Associativity {
    /// Right associative
    case right

    /// Left associative
    case left

    /// No associativity
    case none
}

// ==============================================================================
/// This data type specifies operators that work on values of type `Result`. An
/// operator is either binary infix or unary prefix or postfix. A binary
/// operator has also an associated associativity.
public enum Operator<StreamType: Stream, UserState, Result> {
    /// Infix operator and associativity.
    case infix(
        GenericParser<StreamType, UserState, (Result, Result) -> Result>,
        Associativity
    )

    /// Prefix operator.
    case prefix(GenericParser<StreamType, UserState, (Result) -> Result>)

    /// Postfix operator.
    case postfix(GenericParser<StreamType, UserState, (Result) -> Result>)
}

// ==============================================================================
/// Represents a table of  operators. The `makeExpressionParser()` method is
/// used to create parsers based on the table.
public struct OperatorTable<StreamType: Stream, UserState, Result>:
RangeReplaceableCollection, ExpressibleByArrayLiteral {
    /// Represents a valid position in the operator table.
    public typealias Index = Int

    /// Operator table's generator.
    public typealias Iterator = IndexingIterator<OperatorTable>

    /// Element type of the operator table.
    public typealias Element = [Operator<StreamType, UserState, Result>]

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

    /// Returns the position immediately after i.
    ///
    /// - SeeAlso: `IndexableBase` protocol.
    public func index(after index: OperatorTable.Index) -> OperatorTable.Index {
        return table.index(after: index)
    }

    /// Build an expression parser for terms returned by `combined` with
    /// operators from `self`, taking the associativity and precedence specified
    /// in `self` into account. Prefix and postfix operators of the same
    /// precedence can only occur once (i.e. `--2` is not allowed if `-` is
    /// prefix negate). Prefix and postfix operators of the same precedence
    /// associate to the left (i.e. if `++` is postfix increment, than `-2++`
    /// equals `-1`, not `-3`).
    ///
    /// It takes care of all the complexity involved in building expression
    /// parser. Here is an example of an expression parser that handles prefix
    /// signs, postfix increment and basic arithmetic:
    ///
    ///     func binary(
    ///         name: String,
    ///         function: (Int, Int) -> Int,
    ///         assoc: Associativity
    ///     ) -> Operator<String, (), Int> {
    ///
    ///         let opParser = StringParser.string(name) *>
    ///             GenericParser(result: function)
    ///
    ///         return .Infix(opParser, assoc)
    ///
    ///     }
    ///
    ///     func prefix(
    ///         name: String,
    ///         function: Int -> Int
    ///     ) -> Operator<String, (), Int> {
    ///
    ///         let opParser = StringParser.string(name) *>
    ///             GenericParser(result: function)
    ///
    ///         return .Prefix(opParser)
    ///
    ///     }
    ///
    ///     func postfix(
    ///         name: String,
    ///         function: Int -> Int
    ///     ) -> Operator<String, (), Int> {
    ///
    ///         let opParser = StringParser.string(name) *>
    ///             GenericParser(result: function)
    ///
    ///         return .Postfix(opParser.attempt)
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
    ///             binary("^", function: power, assoc: .right)
    ///         ],
    ///         [
    ///             binary("*", function: *, assoc: .left),
    ///             binary("/", function: /, assoc: .left)
    ///         ],
    ///         [
    ///             binary("+", function: +, assoc: .left),
    ///             binary("-", function: -, assoc: .left)
    ///         ]
    ///
    ///     ]
    ///
    ///     let openingParen = StringParser.character("(")
    ///     let closingParen = StringParser.character(")")
    ///     let decimal = GenericTokenParser<()>.decimal
    ///
    ///     let expression = opTable.makeExpressionParser { expression in
    ///
    ///         expression.between(openingParen, closingParen) <|>
    ///             decimal <?> "simple expression"
    ///
    ///     } <?> "expression"
    ///
    /// - parameters:
    ///   - combine: A function receiving a 'simple expression' as
    ///     parameter that can be nested in other expressions.
    ///   - expression: A parser that can be combined with other expressions.
    /// - returns: An expression parser for terms returned by `combined`
    ///   with operators from `self`.
    /// - SeeAlso:
    ///   `GenericParser.recursive(
    ///       combine: GenericParser -> GenericParser
    ///   ) -> GenericParser
    public func makeExpressionParser(
        _ combine: (
            _ expression: GenericParser<StreamType, UserState, Result>
        ) -> GenericParser<StreamType, UserState, Result>
    ) -> GenericParser<StreamType, UserState, Result> {
        var term: GenericParser<StreamType, UserState, Result>!
        let lazyTerm = GenericParser<StreamType, UserState, Result> { term }

        let expr = reduce(lazyTerm) { buildParser($0, operators: $1) }
        term = combine(expr)

        return expr
    }

    private typealias InfixOperatorParser =
        GenericParser<StreamType, UserState, (Result, Result) -> Result>
    private typealias PrefixOperatorParser =
        GenericParser<StreamType, UserState, (Result) -> Result>
    private typealias PostfixOperatorParser =
        GenericParser<StreamType, UserState, (Result) -> Result>

    private typealias OperatorsTuple = (
        right: [InfixOperatorParser],
        left: [InfixOperatorParser],
        none: [InfixOperatorParser],
        prefix: [PrefixOperatorParser],
        postfix: [PostfixOperatorParser]
    )

    private func buildParser(
        _ term: GenericParser<StreamType, UserState, Result>,
        operators: [Operator<StreamType, UserState, Result>]
    ) -> GenericParser<StreamType, UserState, Result> {
        let ops: OperatorsTuple = operators.reduce( ([], [], [], [], []), splitOperators )

        let rightAssocOp = GenericParser.choice(ops.right)
        let leftAssocOp = GenericParser.choice(ops.left)
        let nonAssocOp = GenericParser.choice(ops.none)
        let prefixOp = GenericParser.choice(ops.prefix)
        let postfixOp = GenericParser.choice(ops.postfix)

        let ambigiousRight = ambigious(rightAssocOp, assoc: LocalizedString("right"))
        let ambigiousLeft = ambigious(leftAssocOp, assoc: LocalizedString("left"))
        let ambigiousNon = ambigious(rightAssocOp, assoc: LocalizedString("non"))

        let prefixParser = prefixOp <|> GenericParser(result: { $0 })
        let postfixParser = postfixOp <|> GenericParser(result: { $0 })

        let termParser = prefixParser >>- { pre in
            term >>- { transform in
                postfixParser >>- { post in
                    GenericParser(result: post(pre(transform)))
                }
            }
        }

        func rightAssocParser( _ left: Result ) -> GenericParser<StreamType, UserState, Result> {
            let rightTerm = termParser >>- { rightAssocParser1($0) }

            let apply = rightAssocOp >>- { transform in
                rightTerm >>- { right in GenericParser(result: transform(left, right)) }
            }

            return apply <|> ambigiousLeft <|> ambigiousNon
        }

        func rightAssocParser1( _ right: Result ) -> GenericParser<StreamType, UserState, Result> {
            return rightAssocParser(right) <|> GenericParser(result: right)
        }

        func leftAssocParser( _ left: Result ) -> GenericParser<StreamType, UserState, Result> {
            let apply = leftAssocOp >>- { transform in
                termParser >>- { right in
                    leftAssocParser1(transform(left, right))
                }
            }
            return apply <|> ambigiousRight <|> ambigiousNon
        }

        func leftAssocParser1( _ right: Result ) -> GenericParser<StreamType, UserState, Result> {
            return leftAssocParser(right) <|> GenericParser(result: right)
        }

        func nonAssocParser( _ left: Result ) -> GenericParser<StreamType, UserState, Result> {
            return nonAssocOp >>- { transform in
                termParser >>- { right in
                    ambigiousRight <|> ambigiousLeft <|> ambigiousNon <|>
                        GenericParser(result: transform(left, right))
                }
            }
        }

        return termParser >>- { transform in
            rightAssocParser(transform) <|>
            leftAssocParser(transform) <|>
            nonAssocParser(transform) <|>
            GenericParser(result: transform) <?> LocalizedString("operator")
        }
    }

    private func splitOperators(
        operators: OperatorsTuple,
        operatorParser: Operator<StreamType, UserState, Result>
    ) -> OperatorsTuple {
        var ops = operators

        switch operatorParser {
        case .infix(let parser, let assoc):

            switch assoc {
            case .none:

                var none = ops.none
                none.append(parser)

                ops.none = none

            case .left:

                var left = ops.left
                left.append(parser)

                ops.left = left

            case .right:

                var right = ops.right
                right.append(parser)

                ops.right = right
            }

        case .prefix(let parser):

            var pre = ops.prefix
            pre.append(parser)

            ops.prefix = pre

        case .postfix(let parser):

            var post = ops.postfix
            post.append(parser)

            ops.postfix = post
        }

        return ops
    }

    private func ambigious(
        _ operatorParser: InfixOperatorParser,
        assoc: String
    ) -> GenericParser<StreamType, UserState, Result> {
        #if _runtime(_ObjC)

        let msg = LocalizedString("ambiguous use of a %@ associative operator")
        let localizedMsg = String.localizedStringWithFormat(msg, assoc as CVarArg)

        #else

        // https://bugs.swift.org/browse/SR-957
        let localizedMsg = LocalizedString("ambiguous use of a \(assoc) associative operator")

        #endif

        return (operatorParser *> GenericParser.fail(localizedMsg)).attempt
    }

    /// Replace the given subRange of elements with newElements.
    ///
    /// - parameters:
    ///   - subRange: Range of elements to replace.
    ///   - newElements: New elements replacing the previous elements contained
    ///     in `subRange`.
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Index>, with newElements: C
    ) where C.Iterator.Element == Iterator.Element {
        table.replaceSubrange(subrange, with: newElements)
    }

    public subscript(position: Index) -> Element { return table[position] }
}
