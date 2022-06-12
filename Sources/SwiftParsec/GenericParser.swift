// ==============================================================================
// GenericParser.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-09-04.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// The primitive parser combinators.
// ==============================================================================
// swiftlint:disable file_length type_body_length function_parameter_count

// ==============================================================================
/// `GenericParser` is a generic implementation of the `Parsec`.
///
/// - requires: StreamType.Iterator has to be a value type.
public final class GenericParser<StreamType: Stream, UserState, Result>:
Parsec {
    /// Create a parser containing the injected result.
    ///
    /// - parameter result: The result to inject into the parser.
    public init(result: Result) {
        parse = { state in
            .none(.ok(result, state,
                      ParseError.unknownParseError(state.position)))
        }
    }

    /// Create a parser containing a function that return a parser. Used to
    /// execute functions lazily.
    ///
    /// - parameter function: The function to execute when the parser is run.
    public init(function: @escaping () -> GenericParser) {
        parse = { state in
            return function().parse(state)
        }
    }

    /// Create an instance with the given parse function.
    init(
        parse: @escaping (
            ParserState<StreamType.Iterator, UserState>
        ) -> Consumed<StreamType, UserState, Result>
    ) {
        self.parse = parse
    }

    /// The function executed when the parser is run.
    ///
    /// - Parameter state: The state of the parser.
    /// - returns: The result of the parsing.
    let parse: (_ state: ParserState<StreamType.Iterator, UserState>)
    -> Consumed<StreamType, UserState, Result>

    /// Return a parser containing the result of mapping transform over `self`.
    ///
    /// This method has the synonym infix operator `<^>`.
    ///
    /// - parameter transform: A mapping function.
    /// - returns: A new parser with the mapped content.
    public func map<T>(
        _ transform: @escaping (Result) -> T
    ) -> GenericParser<StreamType, UserState, T> {
        return GenericParser<StreamType, UserState, T>(parse: { state in
            let consumed = self.parse(state)
            return consumed.map(transform)
        })
    }

    /// Return a parser by applying the function contained in the supplied
    /// parser to self.
    ///
    /// This method has the synonym infix operator `<*>`.
    ///
    /// - parameter parser: The parser containing the function to apply to self.
    /// - returns: A parser with the applied function.
    public func apply<T>(
        _ parser: GenericParser<StreamType, UserState, (Result) -> T>
    ) -> GenericParser<StreamType, UserState, T> {
        return parser >>- { transform in self.map(transform) }
    }

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
    public func alternative(_ altParser: GenericParser) -> GenericParser {
        return GenericParser(parse: { state in
            let consumed = self.parse(state)
            guard case .none(let reply) = consumed,
                case .error(let error) = reply else {
                return consumed
            }

            let altConsumed = altParser.parse(state)
            switch altConsumed {
            case .some: return altConsumed

            case .none(let reply):

                return .none(reply.mergeParseError(error))
            }
        })
    }

    /// Return a parser containing the result of mapping transform over `self`.
    ///
    /// This method has the synonym infix operator `>>-` (bind).
    ///
    /// - parameter transform: A mapping function returning a parser.
    /// - returns: A new parser with the mapped content.
    public func flatMap<T>(
        _ transform: @escaping (
            Result
        ) -> GenericParser<StreamType, UserState, T>
    ) -> GenericParser<StreamType, UserState, T> {
        func runRightParser(
            _ constructor: (
                ParserReply<StreamType, UserState, T>
            ) -> Consumed<StreamType, UserState, T>,
            result: Result,
            state: ParserState<StreamType.Iterator, UserState>,
            error: ParseError
        ) -> Consumed<StreamType, UserState, T> {
            let parser = transform(result)

            let consumed = parser.parse(state)
            switch consumed {
            // If parser consumes, return the result right away.
            case .some: return consumed

            case .none(let reply):

                // If the left parser consumes and the right parser doesn't
                // consume input, but is okay, we return that it successfully
                // consumed some input. But if the left and right parser didn't
                // consume we return that it successfully didn't consumed some
                // input.
                //
                // If the left parser consumes and the right parser doesn't
                // consume input, but errors, we return that it failed while
                // consuming some input. But if the left and right parser didn't
                // consume we return that it failed while not consuming any
                // input.
                return constructor(reply.mergeParseError(error))
            }
        }

        func consumed(
            _ constructor: (
                ParserReply<StreamType, UserState, T>
            ) -> Consumed<StreamType, UserState, T>,
            reply: ParserReply<StreamType, UserState, Result>
        ) -> Consumed<StreamType, UserState, T> {
            switch reply {
            case .ok(let result, let state, let error):

                return runRightParser(constructor, result: result, state: state,
                                      error: error)

            case .error(let error):

                return constructor(.error(error))
            }
        }

        return GenericParser<StreamType, UserState, T>(parse: { state in
            switch self.parse(state) {
            case .some(let reply):

                return consumed(Consumed.some, reply: reply)

            case .none(let reply):

                return consumed(Consumed.none, reply: reply)
            }
        })
    }

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
    public var attempt: GenericParser {
        return GenericParser(parse: { state in
            let consumed = self.parse(state)
            if case .some(let reply) = consumed, case .error = reply {
                return .none(reply)
            }

            return consumed
        })
    }

    /// A combinator that parses without consuming any input.
    ///
    /// If `self` fails and consumes some input, so does `lookAhead`. Combine
    /// with `attempt` if this is undesirable.
    ///
    /// - returns: A parser that parses without consuming any input.
    public var lookAhead: GenericParser {
        return GenericParser(parse: { state in
            let consumed = self.parse(state)

            if case .some(let reply) = consumed,
            case .ok(let result, _, _) = reply {
                return .none(
                    .ok(result,
                        state,
                        ParseError.unknownParseError(state.position)
                    )
                )
            }

            return consumed
        })
    }

    /// The `many` combinator applies the parser `self` _zero_ or more times. It
    /// returns an array of the returned values of `self`.
    ///
    ///     let identifier = identifierStart >>- { char in
    ///
    ///         identifierLetter.many >>- { (var chars) in
    ///
    ///             chars.insert(char, at: 0)
    ///             return GenericParser(result: String(chars))
    ///
    ///         }
    ///
    ///     }
    public var many: GenericParser<StreamType, UserState, [Result]> {
        return manyAccumulator { (result, results) in
            return results.appending(result)
        }
    }

    /// The `skipMany` combinator applies the parser `self` _zero_ or more
    /// times, skipping its result.
    ///
    ///     let spaces = space.skipMany
    ///
    /// - returns: An parser with an empty result.
    public var skipMany: GenericParser<StreamType, UserState, ()> {
        let manyAcc = manyAccumulator { (_, accum: [Result]) in accum }
        return manyAcc.map { _ in () }
    }

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
    public func manyAccumulator<Accumulator: EmptyInitializable>(
        _ accumulator: @escaping (Result, Accumulator) -> Accumulator
    ) -> GenericParser<StreamType, UserState, Accumulator> {
        // swiftlint:disable:next closure_body_length
        return GenericParser<StreamType, UserState, Accumulator>(parse: { initState in
            var results = Accumulator()
            var newState = initState
            var hasConsumed = false

            repeat {
                let consumed = self.parse(newState)
                switch consumed {
                case .some(let reply):
                    switch reply {
                    case .ok(let result, let state, _):
                        results = accumulator(result, results)
                        newState = state

                    case .error(let error):
                        return .some(.error(error))
                    }

                case .none(let reply):
                    switch reply {
                    case .ok:
                        // swiftlint:disable:next line_length
                        let failureMsg = LocalizedString("Combinator 'many' is applied to a parser that accepts an empty string.")
                        assertionFailure(failureMsg)

                    case .error(let error):
                        if hasConsumed { return .some(.ok(results, newState, error)) }
                        return .none(.ok(results, newState, error))
                    }
                }

                hasConsumed = true
            } while true // Loop while the parser consumes.

        })
    }

    /// A parser that always fails without consuming any input.
    public static var empty: GenericParser {
        return GenericParser(parse: { state in
            let position = state.position
            return .none(.error(ParseError.unknownParseError(position)))
        })
    }

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
    public func labels(_ messages: String...) -> GenericParser {
        return GenericParser(parse: { state in
            let consumed = self.parse(state)
            switch consumed {
            case .some: return consumed

            case .none(let reply):

                switch reply {
                case .ok(let result, let state, var error):

                    if !error.isUnknown {
                        error.insertLabelsAsExpected(messages)
                    }

                    return .none(.ok(result, state, error))

                case .error(var error):

                    error.insertLabelsAsExpected(messages)
                    return .none(.error(error))
                }
            }
        })
    }

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
    /// - SeeAlso: `GenericParser.noOccurence`,
    ///   `GenericParser.fail(message: String)` and `<?>`
    public static func unexpected(_ message: String) -> GenericParser {
        return GenericParser { state in
            .none(
                .error(
                    ParseError(
                        position: state.position,
                        messages: [.unexpected(message)]
                    )
                )
            )
        }
    }

    /// Return a parser that always fail with the supplied message.
    ///
    /// - parameter message: The failure message.
    /// - returns: A parser that always fail.
    public static func fail(_ message: String) -> GenericParser {
        return GenericParser(parse: { state in
            let position = state.position
            let error = ParseError(
                position: position,
                messages: [.generic(message)]
            )

            return .none(.error(error))
        })
    }

    /// Return the current source position.
    ///
    /// - returns: The current source position.
    /// - SeeAlso 'SourcePosition'.
    public static var
    sourcePosition: GenericParser<StreamType, UserState, SourcePosition> {
        return GenericParser<StreamType, UserState, SourcePosition>(parse: { state in
            return .none(.ok(state.position, state,
                             ParseError.unknownParseError(state.position)))
        })
    }

    /// Return a parser that applies the result of the supplied parsers to the
    /// lifted function. The parsers are applied from left to right.
    ///
    /// - parameters:
    ///   - function: The Binary function to lift into the parser.
    ///   - parser1: The parser returning the first argument passed to the
    ///     lifted function.
    ///   - parser2: The parser returning the second argument passed to the
    ///     lifted function.
    /// - returns: A parser that applies the result of the supplied parsers to
    ///   the lifted function.
    public static func lift2<Param1, Param2>(
        _ function: @escaping (Param1, Param2) -> Result,
        parser1: GenericParser<StreamType, UserState, Param1>,
        parser2: GenericParser<StreamType, UserState, Param2>
    ) -> GenericParser {
        return parser1 >>- { result1 in
            parser2 >>- { result2 in
                let combinedResult = function(result1, result2)
                return GenericParser(result: combinedResult)
            }
        }
    }

    /// Return a parser that applies the result of the supplied parsers to the
    /// lifted function. The parsers are applied from left to right.
    ///
    /// - parameters:
    ///   - function: The Ternary function to lift into the parser.
    ///   - parser1: The parser returning the first argument passed to the
    ///     lifted function.
    ///   - parser2: The parser returning the second argument passed to the
    ///     lifted function.
    ///   - parser3: The parser returning the third argument passed to the
    ///     lifted function.
    /// - returns: A parser that applies the result of the supplied parsers to
    ///   the lifted function.
    public static func lift3<Param1, Param2, Param3>(
        _ function: @escaping (Param1, Param2, Param3) -> Result,
        parser1: GenericParser<StreamType, UserState, Param1>,
        parser2: GenericParser<StreamType, UserState, Param2>,
        parser3: GenericParser<StreamType, UserState, Param3>
    ) -> GenericParser {
        return parser1 >>- { result1 in
            parser2 >>- { result2 in
                parser3 >>- { result3 in
                    let combinedResult = function(result1, result2, result3)
                    return GenericParser(result: combinedResult)
                }
            }
        }
    }

    /// Return a parser that applies the result of the supplied parsers to the
    /// lifted function. The parsers are applied from left to right.
    ///
    /// - parameters:
    ///   - function: The function to lift into the parser.
    ///   - parser1: The parser returning the first argument passed to the
    ///     lifted function.
    ///   - parser2: The parser returning the second argument passed to the
    ///     lifted function.
    ///   - parser3: The parser returning the third argument passed to the
    ///     lifted function.
    ///   - parser4: The parser returning the fourth argument passed to the
    ///     lifted function.
    /// - returns: A parser that applies the result of the supplied parsers to
    ///   the lifted function.
    public static func lift4<Param1, Param2, Param3, Param4>(
        _ function: @escaping (Param1, Param2, Param3, Param4) -> Result,
        parser1: GenericParser<StreamType, UserState, Param1>,
        parser2: GenericParser<StreamType, UserState, Param2>,
        parser3: GenericParser<StreamType, UserState, Param3>,
        parser4: GenericParser<StreamType, UserState, Param4>
    ) -> GenericParser {
        return parser1 >>- { result1 in
            parser2 >>- { result2 in
                parser3 >>- { result3 in
                    parser4 >>- { result4 in
                        let combinedResult = function(
                            result1,
                            result2,
                            result3,
                            result4
                        )
                        return GenericParser(result: combinedResult)
                    }
                }
            }
        }
    }

    /// Return a parser that applies the result of the supplied parsers to the
    /// lifted function. The parsers are applied from left to right.
    ///
    /// - parameters:
    ///   - function: The function to lift into the parser.
    ///   - parser1: The parser returning the first argument passed to the
    ///     lifted function.
    ///   - parser2: The parser returning the second argument passed to the
    ///     lifted function.
    ///   - parser3: The parser returning the third argument passed to the
    ///     lifted function.
    ///   - parser4: The parser returning the fourth argument passed to the
    ///     lifted function.
    ///   - parser5: The parser returning the fifth argument passed to the
    ///     lifted function.
    /// - returns: A parser that applies the result of the supplied parsers to
    ///   the lifted function.
    public static func lift5<Param1, Param2, Param3, Param4, Param5>(
        _ function: @escaping (Param1, Param2, Param3, Param4, Param5) -> Result,
        parser1: GenericParser<StreamType, UserState, Param1>,
        parser2: GenericParser<StreamType, UserState, Param2>,
        parser3: GenericParser<StreamType, UserState, Param3>,
        parser4: GenericParser<StreamType, UserState, Param4>,
        parser5: GenericParser<StreamType, UserState, Param5>
    ) -> GenericParser {
        return parser1 >>- { result1 in
            parser2 >>- { result2 in
                parser3 >>- { result3 in
                    parser4 >>- { result4 in
                        parser5 >>- { result5 in
                            let combinedResult = function(
                                result1,
                                result2,
                                result3,
                                result4,
                                result5
                            )
                            return GenericParser(result: combinedResult)
                        }
                    }
                }
            }
        }
    }

    /// Return the user state.
    ///
    /// - returns: The user state
    static public var
    userState: GenericParser<StreamType, UserState, UserState> {
        return GenericParser<StreamType, UserState, UserState>(parse: { state in
            return .none(.ok(state.userState, state,
                             ParseError.unknownParseError(state.position)))
        })
    }

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
    public static func updateUserState(
        _ update: @escaping (UserState) -> UserState
    ) -> GenericParser<StreamType, UserState, ()> {
        return GenericParser<StreamType, UserState, ()>(parse: { parserState in
            let userState = update(parserState.userState)

            var state = parserState
            state.userState = userState

            let position = state.position

            return .none(.ok((), state, ParseError.unknownParseError(position)))
        })
    }

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
    public func runSafe(
        userState: UserState,
        sourceName: String,
        input: StreamType
    ) -> Either<ParseError, Result> {
        let position = SourcePosition(name: sourceName, line: 1, column: 1)
        let state = ParserState(
            input: input.makeIterator(),
            position: position,
            userState: userState
        )

        let reply = parse(state).parserReply
        switch reply {
        case .ok(let result, _, _):

            return .right(result)

        case .error(let error):

            return .left(error)
        }
    }
}

// ==============================================================================
// Parsec extension
public extension Parsec {
    // TODO: Move this function into the `Parsec` protocol extension when Swift
    // will allow to add requirements to `associatedtype` type constraint
    // (Ex.: `associatedtype StreamType: CollectionType
    // where StreamType.SubSequence == Stream`)

    /// Return a parser that accepts a token `Element` with `Result` when the
    /// function `match(Element) -> Result` returns
    /// `Optional.SomeWrapped(Result)`. The token can be shown using
    /// `tokenDescription(Element) -> String`. The position of the _next_ token
    /// should be returned when
    /// `nextPosition(SourcePosition, Element, StreamType) -> SourcePosition`
    /// is called with the current source position, the current token and the
    /// rest of the tokens.
    ///
    /// This is the most primitive combinator for accepting tokens. For example,
    /// the `GenericParser.character()` parser could be implemented as:
    ///
    ///     public static func character(
    ///         char: Character
    ///     ) -> GenericParser<StreamType, UserState, Result> {
    ///
    ///         return tokenPrimitive(
    ///             tokenDescription: { "\"" + $0 + "\"" },
    ///             nextPosition: { (var position, elem, _) in
    ///
    ///                 position.updatePosition(elem)
    ///                 return position
    ///
    ///             },
    ///             match: { elem in
    ///
    ///                 char == elem ? elem : nil
    ///
    ///             })
    ///
    ///     }
    ///
    /// - parameters:
    ///   - tokenDescription: A function to describe the token.
    ///   - nextPosition: A function returning the position of the next token.
    ///   - match: A function returning an optional result when the token match
    ///     a predicate.
    /// - returns: Return a parser that accepts a token `Element` with result
    ///   `Result` when the token matches.
    static func tokenPrimitive(
        tokenDescription: @escaping (StreamType.Iterator.Element) -> String,
        nextPosition: @escaping (
            SourcePosition, StreamType.Iterator.Element
        ) -> SourcePosition,
        match: @escaping (StreamType.Iterator.Element) -> Result?
    ) -> GenericParser<StreamType, UserState, Result> {
        return GenericParser(parse: { state in
            var input = state.input
            let position = state.position

            guard let tok = input.next() else {
                let error =
                    ParseError.unexpectedParseError(position, message: "")
                return .none(.error(error))
            }

            guard let result = match(tok) else {
                let error = ParseError.unexpectedParseError(
                    position,
                    message: tokenDescription(tok)
                )
                return .none(.error(error))
            }

            let newPosition = nextPosition(position, tok)
            let newState = ParserState(
                input: input,
                position: newPosition,
                userState: state.userState
            )
            let unknownError = ParseError.unknownParseError(newPosition)

            return .some(.ok(result, newState, unknownError))
        })
    }
}

// ==============================================================================
// Parsec extension where the elements are `Equatable`
public extension Parsec
where StreamType.Iterator.Element: Equatable {
    // TODO: Move this function into the `Parsec` protocol extension when Swift
    // will allow to add requirements to `associatedtype` type constraint
    // (Ex.: `associatedtype StreamType: CollectionType where
    // StreamType.SubSequence == Stream`)

    /// Return a parser that parses a collection of tokens.
    ///
    /// - parameters:
    ///   - tokensDescription: A function to describe the tokens.
    ///   - nextPosition: A function returning the position after the tokens.
    ///   - tokens: The collection of tokens to parse.
    /// - returns: A parser that parses a collection of tokens.
    static func tokens(
        tokensDescription: @escaping (StreamType) -> String,
        nextPosition: @escaping (
            SourcePosition, StreamType
        ) -> SourcePosition,
        tokens: StreamType
    ) -> GenericParser<StreamType, UserState, StreamType> {
        // swiftlint:disable:next closure_body_length
        return GenericParser(parse: { state in
            let position = state.position

            var tokensIterator = tokens.makeIterator()
            var token = tokensIterator.next()

            guard token != nil else {
                let error = ParseError.unknownParseError(position)
                return .none(.ok([], state, error))
            }

            var input = state.input

            var hasConsumed = false
            var consumedConstructor =
                Consumed<StreamType, UserState, StreamType>.none

            repeat {
                guard let inputToken = input.next() else {
                    var eofError =
                        ParseError.unexpectedParseError(position, message: "")
                    eofError.insertMessage(.expected(tokensDescription(tokens)))

                    return consumedConstructor(.error(eofError))
                }

                if token! != inputToken {
                    let tokDesc = tokensDescription([inputToken])

                    var expectedError = ParseError.unexpectedParseError(
                        position,
                        message: tokDesc
                    )

                    let expected = Message.expected(tokensDescription(tokens))
                    expectedError.insertMessage(expected)

                    return consumedConstructor(.error(expectedError))
                }

                if !hasConsumed {
                    hasConsumed = true
                    consumedConstructor = Consumed.some
                }

                token = tokensIterator.next()
            } while token != nil

            let newPosition = nextPosition(position, tokens)
            let newState = ParserState(
                input: input,
                position: newPosition,
                userState: state.userState
            )
            let error = ParseError.unknownParseError(newPosition)

            return .some(.ok(tokens, newState, error))
        })
    }
}

// ==============================================================================
/// The `Consumed` enumeration indicates if a parser consumed some or none from
/// an input.
enum Consumed<StreamType: Stream, UserState, Result> {
    /// Indicates that some of the input was consumed.
    case some(ParserReply<StreamType, UserState, Result>)

    /// Indicates that none of the input was consumed.
    case none(ParserReply<StreamType, UserState, Result>)

    /// The `ParserReply` either from `.some` or `.none`.
    var parserReply: ParserReply<StreamType, UserState, Result> {
        switch self {
        case .some(let reply): return reply

        case .none(let reply): return reply
        }
    }

    /// Return a `Consumed` enumeration containing the result of mapping
    /// transform over the result of the `ParserReply`. In other words it calls
    /// `map` on the parser reply's result.
    ///
    /// - parameter transform: A mapping function.
    /// - returns: A new `Consumed` enumeration with the mapped content.
    func map<T>(
        _ transform: (Result) -> T
    ) -> Consumed<StreamType, UserState, T> {
        switch self {
        case .some(let reply):

            return .some(reply.map(transform))

        case .none(let reply):

            return .none(reply.map(transform))
        }
    }
}

// ==============================================================================
/// The `ParserReply` enumeration indicates the result of a parse.
enum ParserReply<StreamType: Stream, UserState, Result> {
    /// Indicates that the parsing was successfull. It contains a `Result` type,
    /// the `ParserState` and a `ParseError` as associated values.
    case ok(Result, ParserState<StreamType.Iterator, UserState>, ParseError)

    /// Indicates that the parsing failed. It contains a `ParseError` as an
    /// associated value.
    case error(ParseError)

    /// Return a `ParserReply` enumeration containing the result of mapping
    /// transform over `self`.
    ///
    /// - parameter transform: A mapping function.
    /// - returns: A new `ParserReply` enumeration with the mapped content.
    func map<T>(
        _ transform: (Result) -> T
    ) -> ParserReply<StreamType, UserState, T> {
        switch self {
        case .ok(let result, let state, let error):

            return .ok(transform(result), state, error)

        case .error(let error): return .error(error)
        }
    }

    /// Merge the `ParseError` contained by self with the supplied `ParseError`.
    ///
    /// - parameter otherError: The other error to merge with the error
    ///   contained by `self`.
    /// - returns: A new `ParserReply` with the errors merged.
    func mergeParseError(_ otherError: ParseError) -> ParserReply {
        var mergedError = otherError

        switch self {
        case .ok(let parserResult, let parserState, let parserError):

            mergedError.merge(parserError)
            return .ok(parserResult, parserState, mergedError)

        case .error(let parserError):

            mergedError.merge(parserError)
            return .error(mergedError)
        }
    }
}

// ==============================================================================
/// ParserState contains the state of the parser and the user state.
struct ParserState<StreamTypeIterator, UserState> {
    /// The input StreamType of the parser.
    var input: StreamTypeIterator

    /// The position in the input StreamType.
    var position: SourcePosition

    /// The supplied user state.
    var userState: UserState
}

// ==============================================================================
// Implementation of different parser operators.

/// Infix operator for `map`. It has the same precedence as the equality
/// operator (`==`).
///
/// - parameters:
///   - transform: A mapping function.
///   - parser: The parser whose result is mapped.
public func <^><StreamType, UserState, Result, T>(
    transform: @escaping (Result) -> T,
    parser: GenericParser<StreamType, UserState, Result>
) -> GenericParser<StreamType, UserState, T> {
    return parser.map(transform)
}

/// Infix operator for `apply`. It has the same precedence as the equality
/// operator (`==`).
///
/// - parameters:
///   - leftParser: The parser containing the function to apply to the parser on
///     the right.
///   - rightParser: The parser on which the function is applied.
/// - returns: A parser with the applied function.
public func<*><StreamType, UserState, Result, T>(
    leftParser: GenericParser<StreamType, UserState, (Result) -> T>,
    rightParser: GenericParser<StreamType, UserState, Result>
) -> GenericParser<StreamType, UserState, T> {
    return rightParser.apply(leftParser)
}

/// Sequence parsing, discarding the value of the first parser. It has the same
/// precedence as the equality operator (`==`).
///
/// - parameters:
///   - leftParser: The first parser executed.
///   - rightParser: The second parser executed.
/// - returns: A parser returning the result of the second parser.
public func *><StreamType, UserState, Param1, Param2>(
    leftParser: GenericParser<StreamType, UserState, Param1>,
    rightParser: GenericParser<StreamType, UserState, Param2>
) -> GenericParser<StreamType, UserState, Param2> {
    return GenericParser.lift2({ $1 },
        parser1: leftParser,
        parser2: rightParser
    )
}

/// Sequence parsing, discarding the value of the second parser. It has the same
/// precedence as the equality operator (`==`).
///
/// - parameters:
///   - leftParser: The first parser executed.
///   - rightParser: The second parser executed.
/// - returns: A parser returning the result of the first parser.
public func <*<StreamType, UserState, Param1, Param2>(
    leftParser: GenericParser<StreamType, UserState, Param1>,
    rightParser: GenericParser<StreamType, UserState, Param2>
) -> GenericParser<StreamType, UserState, Param1> {
    return GenericParser.lift2({ param, _ in param },
        parser1: leftParser,
        parser2: rightParser
    )
}

/// Infix operator for `flatMap` named _bind_. It has the same precedence as the
/// `nil` coalescing operator (`??`).
///
/// - parameters:
///   - parser: The parser whose result is passed to the `transform` function.
///   - transform: The function receiving the result of `parser`.
public func >>-<StreamType, UserState, Result, T>(
    parser: GenericParser<StreamType, UserState, Result>,
    transform: @escaping (Result) -> GenericParser<StreamType, UserState, T>
) -> GenericParser<StreamType, UserState, T> {
    return parser.flatMap(transform)
}
