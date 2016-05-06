//
//  Primitive.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-04.
//  Copyright © 2015 David Dufresne. All rights reserved.
//
// The primitive parser combinators.
//

import Foundation

/// `GenericParser` is a generic implementation of the `ParsecType`.
///
/// - requires: Stream has to be a value type.
public final class GenericParser<Stream: StreamType, UserState, Result>: ParsecType {
    
    /// Create a parser containing the injected result.
    ///
    /// - parameter result: The result to inject into the parser.
    public init(result: Result) {
        
        parse = { state in
            
            .None(.Ok(result, state, ParseError.unknownParseError(state.position)))
            
        }
        
    }
    
    /// Create a parser containing a function that return a parser. Used to execute functions lazily.
    ///
    /// - parameter function: The function to execute when the parser is run.
    public init(function: () -> GenericParser) {
        
        parse = { state in
            
            return function().parse(state: state)
            
        }
        
    }
    
    /// Create an instance with the given parse function.
    init(parse: ParserState<Stream, UserState> -> Consumed<Stream, UserState, Result>) {
        
        self.parse = parse
        
    }
    
    /// The function executed when the parser is run.
    ///
    /// - Parameter state: The state of the parser.
    /// - returns: The result of the parsing.
    let parse: (state: ParserState<Stream, UserState>) -> Consumed<Stream, UserState, Result>
    
    /// Return a parser containing the result of mapping transform over `self`.
    ///
    /// This method has the synonym infix operator `<^>`.
    ///
    /// - parameter transform: A mapping function.
    /// - returns: A new parser with the mapped content.
    public func map<T>(transform: Result -> T) -> GenericParser<Stream, UserState, T> {
        
        return GenericParser<Stream, UserState, T>(parse: { state in
            
            let consumed = self.parse(state: state)
            return consumed.map(transform)
            
        })
        
    }
    
    /// Return a parser by applying the function contained in the supplied parser to self.
    ///
    /// This method has the synonym infix operator `<*>`.
    ///
    /// - parameter parser: The parser containing the function to apply to self.
    /// - returns: A parser with the applied function.
    public func apply<T>(parser: GenericParser<Stream, UserState, Result -> T>) -> GenericParser<Stream, UserState, T> {
        
        return parser >>- { f in self.map(f) }
        
    }
    
    /// This combinator implements choice. The parser `p.alternative(q)` first applies `p`. If it succeeds, the value of `p` is returned. If `p` fails _without consuming any input_, parser `q` is tried. The parser is called _predictive_ since `q` is only tried when parser `p` didn't consume any input (i.e.. the look ahead is 1). This non-backtracking behaviour allows for both an efficient implementation of the parser combinators and the generation of good error messages.
    ///
    /// This method has the synonym infix operator `<|>`.
    ///
    /// - parameter altParser: The alternative parser to try if `self` fails.
    /// - returns: A parser that will first try `self`. If it consumed no input, it will try `altParser`.
    public func alternative(altParser: GenericParser) -> GenericParser {
        
        return GenericParser(parse: { state in
            
            let consumed = self.parse(state: state)
            guard case .None(let reply) = consumed,
                case .Error(let error) = reply else {
                
                return consumed
                
            }
            
            let altConsumed = altParser.parse(state: state)
            switch altConsumed {
                
            case .Some: return altConsumed
                
            case .None(let reply):
                
                return .None(reply.mergeParseError(error))
                
            }
            
        })
        
    }
    
    /// Return a parser containing the result of mapping transform over `self`.
    ///
    /// This method has the synonym infix operator `>>-` (bind).
    ///
    /// - parameter transform: A mapping function returning a parser.
    /// - returns: A new parser with the mapped content.
    public func flatMap<T>(transform: Result -> GenericParser<Stream, UserState, T>) -> GenericParser<Stream, UserState, T> {
        
        func runRightParser(constructor: ParserReply<Stream, UserState, T> -> Consumed<Stream, UserState, T>, result: Result, state: ParserState<Stream, UserState>, let error: ParseError) -> Consumed<Stream, UserState, T> {
            
            let parser = transform(result)
            
            let consumed = parser.parse(state: state)
            switch consumed {
                
            // If parser consumes, return the result right away.
            case .Some: return consumed
                
            case .None(let reply):
                
                // If the left parser consumes and the right parser doesn't consume input, but is okay, we return that it successfully consumed some input. But if the left and right parser didn't consume we return that it successfully didn't consumed some input.
                // If the left parser consumes and the right parser doesn't consume input, but errors, we return that it failed while consuming some input. But if the left and right parser didn't consume we return that it failed while not consuming any input.
                return constructor(reply.mergeParseError(error))
                
            }
            
        }
        
        func consumed(constructor: (ParserReply<Stream, UserState, T>) -> Consumed<Stream, UserState, T>, reply: ParserReply<Stream, UserState, Result>) -> Consumed<Stream, UserState, T> {
            
            switch reply {
                
            case .Ok(let result, let state, let error):
                
                return runRightParser(constructor, result: result, state: state, error: error)
                
            case .Error(let error):
                
                return constructor(.Error(error))
                
            }
            
        }
        
        return GenericParser<Stream, UserState, T>(parse: { state in
            
            switch self.parse(state: state) {
                
            case .Some(let reply):
                
                return consumed(Consumed.Some, reply: reply)
                
            case .None(let reply):
                
                return consumed(Consumed.None, reply: reply)
                
            }
            
        })
        
    }
    
    /// This combinator is used whenever arbitrary look ahead is needed. Since it pretends that it hasn't consumed any input when `self` fails, the ('<|>') combinator will try its second alternative even when the first parser failed while consuming input.
    ///
    /// The `attempt` combinator can for example be used to distinguish identifiers and reserved words. Both reserved words and identifiers are a sequence of letters. Whenever we expect a certain reserved word where we can also expect an identifier we have to use the `attempt` combinator. Suppose we write:
    ///
    ///     let letExpr = StringParser.string("let")
    ///     let identifier = letter.many1
    ///
    ///     let expr = letExpr <|> identifier <?> "expression"
    ///
    /// If the user writes \"lexical\", the parser fails with: _unexpected 'x', expecting 't' in "let"_. Indeed, since the ('<|>') combinator only tries alternatives when the first alternative hasn't consumed input, the `identifier` parser is never tried (because the prefix "le" of the `string("let")` parser is already consumed). The right behaviour can be obtained by adding the `attempt` combinator:
    ///
    ///     let letExpr = StringParser.string("let")
    ///     let identifier = StringParser.letter.many1
    ///
    ///     let expr = letExpr.attempt <|> identifier <?> "expression"
    ///
    /// - returns: A parser that pretends that it hasn't consumed any input when `self` fails.
    public var attempt: GenericParser {
        
        return GenericParser(parse: { state in
            
            let consumed = self.parse(state: state)
            if case .Some(let reply) = consumed, .Error = reply {
                
                return .None(reply)
                
            }
            
            return consumed
            
        })
        
    }
    
    /// A combinator that parses without consuming any input.
    ///
    /// If `self` fails and consumes some input, so does `lookAhead`. Combine with `attempt` if this is undesirable.
    ///
    /// - returns: A parser that parses without consuming any input.
    public var lookAhead: GenericParser {
        
        return GenericParser(parse: { state in
            
            let consumed = self.parse(state: state)
            if case .Some(let reply) = consumed, .Ok(let result, _, _) = reply {
                
                return .None(.Ok(result, state, ParseError.unknownParseError(state.position)))
                
            }
            
            return consumed
            
        })
        
    }
    
    /// The `many` combinator applies the parser `self` _zero_ or more times. It returns an array of the returned values of `self`.
    ///
    ///     let identifier = identifierStart >>- { char in
    ///
    ///         identifierLetter.many >>- { (var chars) in
    ///
    ///             chars.insert(char, atIndex: 0)
    ///             return GenericParser(result: String(chars))
    ///
    ///         }
    ///
    ///     }
    public var many: GenericParser<Stream, UserState, [Result]> {
        
        return manyAccumulator { (result, results) in
            
            return results.appending(result)
            
        }
        
    }
    
    /// The `skipMany` combinator applies the parser `self` _zero_ or more times, skipping its result.
    ///
    ///     let spaces = space.skipMany
    ///
    /// - returns: An parser with an empty result.
    public var skipMany: GenericParser<Stream, UserState, ()> {
        
        let manyAcc = manyAccumulator { (_, accum: [Result]) in accum }
        return manyAcc.map { _ in () }
        
    }
    
    /// This combinator applies `self` _zero_ or more times. It returns an accumulation of the returned values of `self` that were passed to the `accumulator` function.
    ///
    /// - parameter accumulator: An accumulator function that process the value returned by `self`. The first argument is the value returned by `self` and the second argument is the previous processed values returned by this accumulator function. It returns the result of processing the passed value and the accumulated values.
    /// - returns: The processed values of the accumulator function.
    public func manyAccumulator<Accumulator: EmptyInitializable>(accumulator: (Result, Accumulator) -> Accumulator) -> GenericParser<Stream, UserState, Accumulator> {
        
        return GenericParser<Stream, UserState, Accumulator>(parse: { initState in
            
            var results = Accumulator()
            var newState = initState
            
            var hasConsumed = false
            
            repeat {
                
                let consumed = self.parse(state: newState)
                switch consumed {
                    
                case .Some(let reply):
                    
                    switch reply {
                        
                    case .Ok(let result, let state, _):
                        
                        results = accumulator(result, results)
                        newState = state
                        
                    case .Error(let error):
                        
                        return .Some(.Error(error))
                        
                    }
                    
                case .None(let reply):
                    
                    switch reply {
                        
                    case .Ok:
                        
                        let failureMsg = NSLocalizedString("Combinator 'many' is applied to a parser that accepts an empty string.", comment: "Primitive parsers.")
                        assertionFailure(failureMsg)
                        
                    case .Error(let error):
                        
                        let reply = ParserReply.Ok(results, newState, error)
                        
                        if hasConsumed { return .Some(reply) }
            
                        return .None(reply)
                        
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
            return .None(.Error(ParseError.unknownParseError(position)))
            
        })
        
    }
    
    /// The parser returned by `p.labels(message)` behaves as parser `p`, but whenever the parser `p` fails _without consuming any input_, it replaces expected error messages with the expected error message `message`.
    ///
    /// This is normally used at the end of a set alternatives where we want to return an error message in terms of a higher level construct rather than returning all possible characters. For example, if the `expr` parser from the `attempt` example would fail, the error message is: '...: expecting expression'. Without the `GenericParser.labels()` combinator, the message would be like '...: expecting "let" or "letter"', which is less friendly.
    ///
    /// This method has the synonym infix operator `<?>`.
    ///
    /// - parameter message: The new error message.
    /// - returns: A parser with a replaced error message.
    public func labels(messages: String...) -> GenericParser {
        
        return GenericParser(parse: { state in
            
            let consumed = self.parse(state: state)
            switch consumed {
                
            case .Some: return consumed
                
            case .None(let reply):
                
                switch reply {
                    
                case .Ok(let result, let state, var error):
                    
                    if !error.isUnknown {
                        
                        error.insertLabelsAsExpected(messages)
                        
                    }
                    
                    return .None(.Ok(result, state, error))
                    
                case .Error(var error):
                    
                    error.insertLabelsAsExpected(messages)
                    return .None(.Error(error))
                    
                }
                
            }
            
        })
        
    }
    
    /// Return a parser that always fails with an unexpected error message without consuming any input.
    ///
    /// The parsers 'fail', '\<?\>' and `unexpected` are the three parsers used to generate error messages. Of these, only '<?>' is commonly used. For an example of the use of `unexpected`, see the definition of `GenericParser.noOccurence`.
    ///
    /// - parameter message: The error message.
    /// - returns: A parser that always fails with an unexpected error message without consuming any input.
    /// - SeeAlso: `GenericParser.noOccurence`, `GenericParser.fail(message: String)` and `<?>`
    public static func unexpected(message: String) -> GenericParser {
        
        return GenericParser { state in

            .None(.Error(ParseError(position: state.position, messages: [.Unexpected(message)])))
            
        }
        
    }
    
    /// Return a parser that always fail with the supplied message.
    ///
    /// - parameter message: The failure message.
    /// - returns: A parser that always fail.
    public static func fail(message: String) -> GenericParser {
        
        return GenericParser(parse: { state in
            
            let position = state.position
            let error = ParseError(position: position, messages: [.Generic(message)])
            
            return .None(.Error(error))
            
        })
        
    }
    
    /// Return a parser that applies the result of the supplied parsers to the lifted function. The parsers are applied from left to right.
    ///
    /// - parameters:
    ///   - function: The Binary function to lift into the parser.
    ///   - parser1: The parser returning the first argument passed to the lifted function.
    ///   - parser2: The parser returning the second argument passed to the lifted function.
    /// - returns: A parser that applies the result of the supplied parsers to the lifted function.
    public static func lift2<Param1, Param2>(function: (Param1, Param2) -> Result, parser1: GenericParser<Stream, UserState, Param1>, parser2: GenericParser<Stream, UserState, Param2>) -> GenericParser {
        
        return parser1 >>- { result1 in
            
            parser2 >>- { result2 in
                
                let combinedResult = function(result1, result2)
                return GenericParser(result: combinedResult)
                
            }
            
        }
        
    }
    
    /// Return a parser that applies the result of the supplied parsers to the lifted function. The parsers are applied from left to right.
    ///
    /// - parameters:
    ///   - function: The Ternary function to lift into the parser.
    ///   - parser1: The parser returning the first argument passed to the lifted function.
    ///   - parser2: The parser returning the second argument passed to the lifted function.
    ///   - parser3: The parser returning the third argument passed to the lifted function.
    /// - returns: A parser that applies the result of the supplied parsers to the lifted function.
    public static func lift3<Param1, Param2, Param3>(function: (Param1, Param2, Param3) -> Result, parser1: GenericParser<Stream, UserState, Param1>, parser2: GenericParser<Stream, UserState, Param2>, parser3: GenericParser<Stream, UserState, Param3>) -> GenericParser {
        
        return parser1 >>- { result1 in
            
            parser2 >>- { result2 in
                
                parser3 >>- { result3 in
                    
                    let combinedResult = function(result1, result2, result3)
                    return GenericParser(result: combinedResult)
                    
                }

            }
            
        }

    }
    
    /// Return a parser that applies the result of the supplied parsers to the lifted function. The parsers are applied from left to right.
    ///
    /// - parameters:
    ///   - function: The function to lift into the parser.
    ///   - parser1: The parser returning the first argument passed to the lifted function.
    ///   - parser2: The parser returning the second argument passed to the lifted function.
    ///   - parser3: The parser returning the third argument passed to the lifted function.
    ///   - parser4: The parser returning the fourth argument passed to the lifted function.
    /// - returns: A parser that applies the result of the supplied parsers to the lifted function.
    public static func lift4<Param1, Param2, Param3, Param4>(function: (Param1, Param2, Param3, Param4) -> Result, parser1: GenericParser<Stream, UserState, Param1>, parser2: GenericParser<Stream, UserState, Param2>, parser3: GenericParser<Stream, UserState, Param3>, parser4: GenericParser<Stream, UserState, Param4>) -> GenericParser {
        
        return parser1 >>- { result1 in
            
            parser2 >>- { result2 in
                
                parser3 >>- { result3 in
                    
                    parser4 >>- { result4 in
                        
                        let combinedResult = function(result1, result2, result3, result4)
                        return GenericParser(result: combinedResult)
                        
                    }

                }
                
            }
            
        }

    }
    
    /// Return a parser that applies the result of the supplied parsers to the lifted function. The parsers are applied from left to right.
    ///
    /// - parameters:
    ///   - function: The function to lift into the parser.
    ///   - parser1: The parser returning the first argument passed to the lifted function.
    ///   - parser2: The parser returning the second argument passed to the lifted function.
    ///   - parser3: The parser returning the third argument passed to the lifted function.
    ///   - parser4: The parser returning the fourth argument passed to the lifted function.
    ///   - parser5: The parser returning the fifth argument passed to the lifted function.
    /// - returns: A parser that applies the result of the supplied parsers to the lifted function.
    public static func lift5<Param1, Param2, Param3, Param4, Param5>(function: (Param1, Param2, Param3, Param4, Param5) -> Result, parser1: GenericParser<Stream, UserState, Param1>, parser2: GenericParser<Stream, UserState, Param2>, parser3: GenericParser<Stream, UserState, Param3>, parser4: GenericParser<Stream, UserState, Param4>, parser5: GenericParser<Stream, UserState, Param5>) -> GenericParser {
        
        return parser1 >>- { result1 in
            
            parser2 >>- { result2 in
                
                parser3 >>- { result3 in
                    
                    parser4 >>- { result4 in
                        
                        parser5 >>- { result5 in
                            
                            let combinedResult = function(result1, result2, result3, result4, result5)
                            return GenericParser(result: combinedResult)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }

    }
    
    /// The `updateUserState` method applies the function `update` to the user state. Suppose that we want to count identifiers in a source, we could use the user state as:
    ///
    ///     let incrementCount = StringParser.updateUserState { ++$0 }
    ///     let expr = identifier <* incrementCount
    ///
    /// - parameter update: The function applied to the `UserState`. It returns the updated `UserState`.
    /// - returns: An empty parser that will update the `UserState`.
    public static func updateUserState(update: UserState -> UserState) -> GenericParser<Stream, UserState, ()> {
        
        return GenericParser<Stream, UserState, ()>(parse: { parserState in
            
            let userState = update(parserState.userState)
            
            var state = parserState
            state.userState = userState
            
            let position = state.position
            
            return .None(.Ok((), state, ParseError.unknownParseError(position)))
            
        })
        
    }
    
    /// Run the parser and return the result of the parsing and the user state.
    ///
    /// - parameters:
    ///   - userState: The state supplied by the user.
    ///   - sourceName: The name of the source (i.e. file name).
    ///   - input: The input stream to parse.
    /// - throws: A `ParseError` when an error occurs.
    /// - returns: The result of the parsing and the user state.
    public func run(userState userState: UserState, sourceName: String, input: Stream) throws -> (result: Result, userState: UserState) {
        
        let position = SourcePosition(name: sourceName, line: 1, column: 1)
        let state = ParserState(input: input, position: position, userState: userState)
        
        let reply = parse(state: state).parserReply
        switch reply {
            
        case .Ok(let result, let state, _):
            
            return (result, state.userState)
            
        case .Error(let error):
            
            throw error
            
        }
        
    }
    
}

/// The `Consumed` enumeration indicates if a parser consumed some or none from an input.
enum Consumed<Stream, UserState, Result> {
    
    /// Indicates that some of the input was consumed.
    case Some(ParserReply<Stream, UserState, Result>)
    
    /// Indicates that none of the input was consumed.
    case None(ParserReply<Stream, UserState, Result>)
    
    /// The `ParserReply` either from `.Some` or `.None`.
    var parserReply: ParserReply<Stream, UserState, Result> {
        
        switch self {
            
        case .Some(let reply): return reply
            
        case .None(let reply): return reply
            
        }
        
    }
    
    /// Return a `Consumed` enumeration containing the result of mapping transform over the result of the `ParserReply`. In other words it calls `map` on the parser reply's result.
    ///
    /// - parameter transform: A mapping function.
    /// - returns: A new `Consumed` enumeration with the mapped content.
    func map<T>(transform: Result -> T) -> Consumed<Stream, UserState, T> {
        
        switch self {
            
        case .Some(let reply):
            
            return .Some(reply.map(transform))
            
        case .None(let reply):
            
            return .None(reply.map(transform))
        }
        
    }
    
}

/// The `ParserReply` enumeration indicates the result of a parse.
enum ParserReply<Stream, UserState, Result> {
    
    /// Indicates that the parsing was successfull. It contains a `Result` type, the `ParserState` and a `ParseError` as associated values.
    case Ok(Result, ParserState<Stream, UserState>, ParseError)
    
    /// Indicates that the parsing failed. It contains a `ParseError` as an associated value.
    case Error(ParseError)
    
    /// Return a `ParserReply` enumeration containing the result of mapping transform over `self`.
    ///
    /// - parameter transform: A mapping function.
    /// - returns: A new `ParserReply` enumeration with the mapped content.
    func map<T>(transform: Result -> T) -> ParserReply<Stream, UserState, T> {
        
        switch self {
            
        case .Ok(let result, let state, let error):
            
            return .Ok(transform(result), state, error)
            
        case .Error(let error): return .Error(error)
            
        }
        
    }
    
    /// Merge the `ParseError` contained by self with the supplied `ParseError`.
    ///
    /// - parameter otherError: The other error to merge with the error contained by `self`.
    /// - returns: A new `ParserReply` with the errors merged.
    func mergeParseError(otherError: ParseError) -> ParserReply {
        
        var mergedError = otherError
        
        switch self {
            
        case .Ok(let parserResult, let parserState, let parserError):
            
            mergedError.merge(parserError)
            return .Ok(parserResult, parserState, mergedError)
            
        case .Error(let parserError):
            
            mergedError.merge(parserError)
            return .Error(mergedError)
            
        }
        
    }
    
}

/// ParserState contains the state of the parser and the user state.
struct ParserState<Stream, UserState> {
    
    /// The input stream of the parser.
    var input: Stream
    
    /// The position in the input stream.
    var position: SourcePosition
    
    /// The supplied user state.
    var userState: UserState
    
}

/// Infix operator for `map`. It has the same precedence as the equality operator (`==`).
///
/// - parameters:
///   - transform: A mapping function.
///   - parser: The parser whose result is mapped.
public func <^><Stream, UserState, Result, T>(transform: Result -> T, parser: GenericParser<Stream, UserState, Result>) -> GenericParser<Stream, UserState, T> {
    
    return parser.map(transform)
    
}

/// Infix operator for `apply`. It has the same precedence as the equality operator (`==`).
///
/// - parameters:
///   - leftParser: The parser containing the function to apply to the parser on the right.
///   - rightParser: The parser on which the function is applied.
/// - returns: A parser with the applied function.
public func<*><Stream, UserState, Result, T>(leftParser: GenericParser<Stream, UserState, Result -> T>, rightParser: GenericParser<Stream, UserState, Result>) -> GenericParser<Stream, UserState, T> {
    
    return rightParser.apply(leftParser)
    
}

/// Sequence parsing, discarding the value of the first parser. It has the same precedence as the equality operator (`==`).
///
/// - parameters:
///   - leftParser: The first parser executed.
///   - rightParser: The second parser executed.
/// - returns: A parser returning the result of the second parser.
public func *><Stream, UserState, Param1, Param2>(leftParser: GenericParser<Stream, UserState, Param1>, rightParser: GenericParser<Stream, UserState, Param2>) -> GenericParser<Stream, UserState, Param2> {
    
    return GenericParser.lift2({ $1 }, parser1: leftParser, parser2: rightParser)
    
}

/// Sequence parsing, discarding the value of the second parser. It has the same precedence as the equality operator (`==`).
///
/// - parameters:
///   - leftParser: The first parser executed.
///   - rightParser: The second parser executed.
/// - returns: A parser returning the result of the first parser.
public func <*<Stream, UserState, Param1, Param2>(leftParser: GenericParser<Stream, UserState, Param1>, rightParser: GenericParser<Stream, UserState, Param2>) -> GenericParser<Stream, UserState, Param1> {
    
    return GenericParser.lift2({ $0.0 }, parser1: leftParser, parser2: rightParser)
    
}

/// Infix operator for `ParsecType.alternative`. It has the same precedence as the equality operator (`&&`).
///
/// - parameters:
///   - leftParser: The first parser to try.
///   - rightParser: The second parser to try.
public func <|><Stream, UserState, Result>(leftParser: GenericParser<Stream, UserState, Result>, rightParser: GenericParser<Stream, UserState, Result>) -> GenericParser<Stream, UserState, Result> {
    
    return leftParser.alternative(rightParser)
    
}

/// Infix operator for `flatMap` named _bind_. It has the same precedence as the `nil` coalescing operator (`??`).
///
/// - parameters:
///   - parser: The parser whose result is passed to the `transform` function.
///   - transform: The function receiving the result of `parser`.
public func >>-<Stream, UserState, Result, T>(parser: GenericParser<Stream, UserState, Result>, transform: Result -> GenericParser<Stream, UserState, T>) -> GenericParser<Stream, UserState, T> {
    
    return parser.flatMap(transform)
    
}

/// Infix operator for `label`. It has the lowest precedence.
///
/// - parameters:
///   - parser: The parser whose error message is to be replaced.
///   - message: The new error message.
public func <?><Stream, UserState, Result>(parser: GenericParser<Stream, UserState, Result>, message: String) -> GenericParser<Stream, UserState, Result> {
    
    return parser.labels(message)
    
}
