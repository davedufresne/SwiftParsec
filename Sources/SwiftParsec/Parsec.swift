// ==============================================================================
// Parsec.swift
// SwiftParsec
//
// Created by David Dufresne on 2016-05-02.
// Copyright © 2016 David Dufresne. All rights reserved.
//
// Parsec protocol and related operator definitions.
// ==============================================================================

// TODO: - Make `Parsec` the model of a true monad when Swift will allow it.

// ==============================================================================
/// `Parsec` is a parser with stream type `Stream`, user state type `UserState`
/// and return type `Result`.
public protocol Parsec {
    /// The input stream to parse.
    associatedtype StreamType: Stream

    /// The state supplied by the user.
    associatedtype UserState

    /// The result of the parser.
    associatedtype Result

    /// Return a parser containing the result of mapping transform over `self`.
    ///
    /// This method has the synonym infix operator `<^>`.
    ///
    /// - parameter transform: A mapping function.
    /// - returns: A new parser with the mapped content.
    func map<T>(
        _ transform: @escaping (Result) -> T
    ) -> GenericParser<StreamType, UserState, T>

    /// Return a parser by applying the function contained in the supplied
    /// parser to self.
    ///
    /// This method has the synonym infix operator `<*>`.
    ///
    /// - parameter parser: The parser containing the function to apply to self.
    /// - returns: A parser with the applied function.
    func apply<T>(
        _ parser: GenericParser<StreamType, UserState, (Result) -> T>
    ) -> GenericParser<StreamType, UserState, T>

    /// This combinator implements choice. The parser `p.alternative(q)` first
    /// applies `p`. If it succeeds, the value of `p` is returned. If `p` fails
    /// _without consuming any input_, parser `q` is tried. The parser is called
    /// _predictive_ since `q` is only tried when parser `p` didn't consume any
    /// input (i.e.. the look ahead is 1). This non-backtracking behaviour
    /// allows for both an efficient implementation of the parser combinators
    /// and the generation of good error messages.
    ///
    /// This method has the synonym infix operator `<|>`.
    ///
    /// - parameter altParser: The alternative parser to try if `self` fails.
    /// - returns: A parser that will first try `self`. If it consumed no input,
    ///   it will try `altParser`.
    func alternative(_ altParser: Self) -> Self

    /// Return a parser containing the result of mapping transform over `self`.
    ///
    /// This method has the synonym infix operator `>>-` (bind).
    ///
    /// - parameter transform: A mapping function returning a parser.
    /// - returns: A new parser with the mapped content.
    func flatMap<T>(
        _ transform: @escaping (
            Result
        ) -> GenericParser<StreamType, UserState, T>
    ) -> GenericParser<StreamType, UserState, T>

    /// This combinator is used whenever arbitrary look ahead is needed. Since
    /// it pretends that it hasn't consumed any input when `self` fails, the
    /// ('<|>') combinator will try its second alternative even when the first
    /// parser failed while consuming input.
    ///
    /// The `attempt` combinator can for example be used to distinguish
    /// identifiers and reserved words. Both reserved words and identifiers are
    /// a sequence of letters. Whenever we expect a certain reserved word where
    /// we can also expect an identifier we have to use the `attempt`
    /// combinator. Suppose we write:
    ///
    ///     let letExpr = StringParser.string("let")
    ///     let identifier = letter.many1
    ///
    ///     let expr = letExpr <|> identifier <?> "expression"
    ///
    /// If the user writes \"lexical\", the parser fails with: _unexpected 'x',
    /// expecting 't' in "let"_. Indeed, since the ('<|>') combinator only tries
    /// alternatives when the first alternative hasn't consumed input, the
    /// `identifier` parser is never tried (because the prefix "le" of the
    /// `string("let")` parser is already consumed). The right behaviour can be
    /// obtained by adding the `attempt` combinator:
    ///
    ///     let letExpr = StringParser.string("let")
    ///     let identifier = StringParser.letter.many1
    ///
    ///     let expr = letExpr.attempt <|> identifier <?> "expression"
    ///
    /// - returns: A parser that pretends that it hasn't consumed any input when
    ///   `self` fails.
    var attempt: Self { get }

    /// A combinator that parses without consuming any input.
    ///
    /// If `self` fails and consumes some input, so does `lookAhead`. Combine
    /// with `attempt` if this is undesirable.
    ///
    /// - returns: A parser that parses without consuming any input.
    var lookAhead: Self { get }

    /// This combinator applies `self` _zero_ or more times. It returns an
    /// accumulation of the returned values of `self` that were passed to the
    /// `accumulator` function.
    ///
    /// - parameter accumulator: An accumulator function that process the value
    ///   returned by `self`. The first argument is the value returned by `self`
    ///   and the second argument is the previous processed values returned by
    ///   this accumulator function. It returns the result of processing the
    ///   passed value and the accumulated values.
    /// - returns: The processed values of the accumulator function.
    func manyAccumulator(
        _ accumulator: @escaping (Result, [Result]) -> [Result]
    ) -> GenericParser<StreamType, UserState, [Result]>

    /// A parser that always fails without consuming any input.
    static var empty: Self { get }

    /// The parser returned by `p.labels(message)` behaves as parser `p`, but
    /// whenever the parser `p` fails _without consuming any input_, it replaces
    /// expected error messages with the expected error message `message`.
    ///
    /// This is normally used at the end of a set alternatives where we want to
    /// return an error message in terms of a higher level construct rather than
    /// returning all possible characters. For example, if the `expr` parser
    /// from the `attempt` example would fail, the error message is: '...:
    /// expecting expression'. Without the `GenericParser.labels()` combinator,
    /// the message would be like '...: expecting "let" or "letter"', which is
    /// less friendly.
    ///
    /// This method has the synonym infix operator `<?>`.
    ///
    /// - parameter message: The new error message.
    /// - returns: A parser with a replaced error message.
    func labels(_ message: String...) -> Self

    /// Return a parser that always fails with an unexpected error message
    /// without consuming any input.
    ///
    /// The parsers 'fail', '\<?\>' and `unexpected` are the three parsers used
    /// to generate error messages. Of these, only '<?>' is commonly used. For
    /// an example of the use of `unexpected`, see the definition of
    /// `GenericParser.noOccurence`.
    ///
    /// - parameter message: The error message.
    /// - returns: A parser that always fails with an unexpected error message
    ///   without consuming any input.
    /// - SeeAlso: `GenericParser.noOccurence`, `GenericParser.fail(message:
    ///   String)` and `<?>`
    static func unexpected(_ message: String) -> Self

    /// Return a parser that always fails with the supplied message.
    ///
    /// - parameter message: The failure message.
    /// - returns: A parser that always fail.
    static func fail(_ message: String) -> Self

    /// Return the current source position.
    ///
    /// - returns: The current source position.
    /// - SeeAlso 'SourcePosition'.
    static var
    sourcePosition: GenericParser<StreamType, UserState, SourcePosition> { get }

    /// Return the user state.
    ///
    /// - returns: The user state
    static var
    userState: GenericParser<StreamType, UserState, UserState> { get }

    /// The `updateUserState` method applies the function `update` to the user
    /// state. Suppose that we want to count identifiers in a source, we could
    /// use the user state as:
    ///
    ///     let incrementCount = StringParser.updateUserState { ++$0 }
    ///     let expr = identifier <* incrementCount
    ///
    /// - parameter update: The function applied to the `UserState`. It returns
    ///   the updated `UserState`.
    /// - returns: An empty parser that will update the `UserState`.
    static func updateUserState(
        _ update: @escaping (UserState) -> UserState
    ) -> GenericParser<StreamType, UserState, ()>

    /// Run the parser and return the result of the parsing if it succeeded.
    /// If an error occured, it is returned. Contrary to the `run()` method, it
    /// doesn't throw an exception.
    ///
    /// - parameters:
    ///   - userState: The state supplied by the user.
    ///   - sourceName: The name of the source (i.e. file name).
    ///   - input: The input StreamType to parse.
    /// - returns: The result of the parsing on success, otherwise the parse
    ///   error.
    func runSafe(
        userState: UserState,
        sourceName: String,
        input: StreamType
    ) -> Either<ParseError, Result>
}

// ==============================================================================
// Operator definitions.

/// Precedence of infix operator for `Parsec.labels()`. It has a higher
/// precedence than the `AssignmentPrecedence` group but a lower precedence than
/// the `LogicalDisjunctionPrecedence` group.
precedencegroup LabelPrecedence {
    associativity: right
    higherThan: AssignmentPrecedence
    lowerThan: LogicalDisjunctionPrecedence
}

/// Infix operator for `Parsec.labels()`. It has the lowest precedence of the
/// parsers operators.
infix operator <?> : LabelPrecedence

/// Precedence of infix operator for `Parsec.flatMap()` (bind). It has a higher
/// precedence than the `LabelPrecedence` group.
precedencegroup FlatMapPrecedence {
    associativity: left
    higherThan: LabelPrecedence
}

/// Infix operator for `Parsec.flatMap()` (bind). It has a higher precedence
/// than the `<?>` operator.
infix operator >>- : FlatMapPrecedence

/// Precedence of infix operator for `Parsec.alternative()`. It has a higher
/// precedence than the `FlatMapPrecedence` group.
precedencegroup ChoicePrecedence {
    associativity: left
    higherThan: FlatMapPrecedence
}

/// Infix operator for `Parsec.alternative()`. It has a higher precedence than
/// the `>>-` operator.
infix operator <|> : ChoicePrecedence

/// Precedence of infix operators for sequence parsing. It has a higher
/// precedence than the `ChoicePrecedence` group.
precedencegroup SequencePrecedence {
    associativity: left
    higherThan: ChoicePrecedence
}

/// Sequence parsing, discarding the value of the first parser. It has a higher
/// precedence than the `<|>` operator.
infix operator *> : SequencePrecedence

/// Sequence parsing, discarding the value of the second parser. It has a higher
/// precedence than the `<|>` operator.
infix operator <* : SequencePrecedence

/// Infix operator for `Parsec.apply()`. It has a higher precedence than the
/// `<|>` operator.
infix operator <*> : SequencePrecedence

/// Infix operator for `Parsec.map()`. It has a higher precedence than the `<|>`
/// operator.
infix operator <^> : SequencePrecedence

extension Parsec {
    /// Infix operator for `Parsec.labels()`. It has the lowest precedence of the
    /// parsers operators.
    ///
    /// - parameters:
    ///   - parser: The parser whose error message is to be replaced.
    ///   - message: The new error message.
    public static func <?> (parser: Self, message: String) -> Self {
        return parser.labels(message)
    }

    /// Infix operator for `Parsec.alternative`. It has a higher precedence than
    /// the `>>-` operator.
    ///
    /// - parameters:
    ///   - leftParser: The first parser to try.
    ///   - rightParser: The second parser to try.
    public static func <|> (leftParser: Self, rightParser: Self) -> Self {
        return leftParser.alternative(rightParser)
    }
}

// ==============================================================================
// Extension containing useful methods to run a parser.
public extension Parsec {
    /// Run the parser and return the result of the parsing.
    ///
    /// - parameters:
    ///   - userState: The state supplied by the user.
    ///   - sourceName: The name of the source (i.e. file name).
    ///   - input: The input stream to parse.
    /// - throws: A `ParseError` when an error occurs.
    /// - returns: The result of the parsing.
    func run(
        userState: UserState,
        sourceName: String,
        input: StreamType
        ) throws -> Result {
        let result = runSafe(
            userState: userState,
            sourceName: sourceName,
            input: input
        )

        switch result {
        case .left(let error):

            throw error

        case .right(let result):

            return result
        }
    }
}

// ==============================================================================
// Extension containing useful methods to run a parser with an empty user state.
public extension Parsec where UserState == () {
    /// Run the parser and return the result of the parsing.
    ///
    /// - parameters:
    ///   - userState: The state supplied by the user.
    ///   - sourceName: The name of the source (i.e. file name).
    ///   - input: The input stream to parse.
    /// - throws: A `ParseError` when an error occurs.
    /// - returns: The result of the parsing.
    func run(sourceName: String, input: StreamType) throws -> Result {
        return try run(
            userState: (),
            sourceName: sourceName,
            input: input
        )
    }

    /// Used for testing parsers. It applies `self` against `input` and prints
    /// the result.
    ///
    /// - parameter input: The input stream to parse.
    func test(input: StreamType) {
        do {
            let result = try run(sourceName: "", input: input)
            print(result)
        } catch let parseError as ParseError {
            let parseErrorMsg = LocalizedString("parse error at ")
            print(parseErrorMsg + String(describing: parseError))
        } catch let error {
            print(String(describing: error))
        }
    }
}

// ==============================================================================
// Extension containing useful methods to run a parser.
/// A `Stream` instance is responsible for maintaining the position of the
/// parser's stream.
public protocol Stream: Collection, ExpressibleByArrayLiteral
where ArrayLiteralElement == Element {}

extension String: Stream {
    /// Create an instance containing `elements`.
    public init(arrayLiteral elements: String.Iterator.Element...) {
        self.init(elements)
    }
}

// ==============================================================================
/// Types conforming to the `EmptyInitializable` protocol provide an empty
/// intializer.
public protocol EmptyInitializable {
    init()
}

// ==============================================================================
// Extensions implementing the `Stream` protocol for various collections.

extension Array: Stream, EmptyInitializable {}

extension ContiguousArray: Stream, EmptyInitializable {}

extension ArraySlice: Stream, EmptyInitializable {}

extension Dictionary: EmptyInitializable {}

extension Set: EmptyInitializable {}
