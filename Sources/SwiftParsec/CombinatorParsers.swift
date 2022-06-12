// ==============================================================================
// CombinatorParsers.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-09-26.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// Commonly used generic combinators
// ==============================================================================
// swiftlint:disable file_length

// ==============================================================================
// Extension containing methods related to parser combinators.
public extension GenericParser {
    /// Return a parser that tries to apply the parsers in the array `parsers`
    /// in order, until one of them succeeds. It returns the value of the
    /// succeeding parser.
    ///
    /// - parameter parsers: An array of parsers to try.
    /// - returns: A parser that tries to apply the parsers in the array
    ///   `parsers` in order, until one of them succeeds.
    static func choice<S: Sequence>(_ parsers: S) -> GenericParser
    where S.Iterator.Element == GenericParser {
        return parsers.reduce(GenericParser.empty, <|>)
    }

    /// A parser that tries to apply `self`. If `self` fails without consuming
    /// input, it returns `nil`, otherwise it returns the value returned by
    /// `self`.
    var optional: GenericParser<StreamType, UserState, Result?> {
        return map({ $0 }).otherwise(nil)
    }

    /// Return a parser that tries to apply `self`. If `self` fails without
    /// consuming input, it returns `result`, or else the value returned by
    /// `self`.
    ///
    /// - parameter result: The result to return if `self` fails without
    ///   consuming input.
    /// - returns: A parser that tries to apply `self`. If `self` fails without
    ///   consuming input, it returns `result`.
    func otherwise(_ result: Result) -> GenericParser {
        return self <|> GenericParser(result: result)
    }

    /// A parser that tries to apply `self`. It will parse `self` or nothing.
    /// It only fails if `self` fails after consuming input. It discards the
    /// result of `self`.
    var discard: GenericParser<StreamType, UserState, ()> {
        return map { _ in () } <|> GenericParser<StreamType, UserState, ()>(
            result: ()
        )
    }

    /// Return a parser that parses `opening`, followed by `self` and `closing`.
    /// It returns the value returned by `self`.
    ///
    /// - parameters:
    ///   - opening: The first parser to apply.
    ///   - closing: The last parser to apply.
    /// - returns: A parser that parses `opening`, followed by `self` and
    ///   `closing`.
    func between<U, V>(
        _ opening: GenericParser<StreamType, UserState, U>,
        _ closing: GenericParser<StreamType, UserState, V>
    ) -> GenericParser {
        return opening *> self <* closing
    }

    /// A parser that applies `self` _one_ or more times, skipping its result.
    var skipMany1: GenericParser<StreamType, UserState, ()> {
        return self >>- { _ in self.skipMany }
    }

    /// A parser that applies `self` _one_ or more times. It returns an array of
    /// the returned values of `self`.
    ///
    ///     let word = StringParser.letter.many1
    var many1: GenericParser<StreamType, UserState, [Result]> {
        return self >>- { result in
            self.many >>- { results in
                let allResults = results.prepending(result)
                return GenericParser<StreamType, UserState, [Result]>(
                    result: allResults
                )
            }
        }
    }

    /// Return a parser that parses _zero_ or more occurrences of `self`,
    /// separated by `separator`. It returns an array of values returned by
    /// `self`.
    ///
    ///     let comma = StringParser.character(",")
    ///     let letter = StringParser.letter
    ///     let commaSeparated = letter.separatedBy(comma)
    ///
    /// - parameter separator: The separator parser.
    /// - returns: A parser that parses _zero_ or more occurrences of `self`,
    ///   separated by `separator`.
    func separatedBy<Separator>(
        _ separator: GenericParser<StreamType, UserState, Separator>
    ) -> GenericParser<StreamType, UserState, [Result]> {
        return separatedBy1(separator) <|>
            GenericParser<StreamType, UserState, [Result]>(result: [])
    }

    /// Return a parser that parses _one_ or more occurrences of `self`,
    /// separated by `separator`. It returns an array of values returned by
    /// `self`.
    ///
    /// - parameter separator: The separator parser.
    /// - returns: A parser that parses _one_ or more occurrences of `self`,
    ///   separated by `separator`.
    func separatedBy1<Separator>(
        _ separator: GenericParser<StreamType, UserState, Separator>
    ) -> GenericParser<StreamType, UserState, [Result]> {
        return self >>- { result in
            (separator *> self).many >>- { results in
                let allResults = results.prepending(result)
                return GenericParser<StreamType, UserState, [Result]>(
                    result: allResults
                )
            }
        }
    }

    /// Return a parser that parses _zero_ or more occurrences of `self`,
    /// separated and optionally ended by `separator`. It returns an array of
    /// values returned by `self`.
    ///
    ///     let cStatements = cStatement.dividedBy(semicolon)
    ///
    ///     let swiftStatements = swiftStatement.dividedBy(semicolon,
    ///         endSeparatorRequired: false)
    ///
    /// - parameters:
    ///   - separator: The separator parser.
    ///   - endSeparatorRequired: Indicates if the separator is required at the
    ///     end. The default value is true.
    /// - returns: A parser that parses _zero_ or more occurrences of `self`,
    ///   separated and optionally ended by `separator`.
    func dividedBy<Separator>(
        _ separator: GenericParser<StreamType, UserState, Separator>,
        endSeparatorRequired: Bool = true
    ) -> GenericParser<StreamType, UserState, [Result]> {
        if endSeparatorRequired {
            return (self <* separator).many
        }

        return dividedBy1(separator, endSeparatorRequired: false) <|>
            GenericParser<StreamType, UserState, [Result]>(result: [])
    }

    /// Return a parser that parses _one_ or more occurrences of `self`,
    /// separated and optionally ended by `separator`. It returns an array of
    /// values returned by `self`.
    ///
    /// - parameters:
    ///   - separator: The separator parser.
    ///   - endSeparatorRequired: Indicates if the separator is required at the
    ///     end. The default value is true.
    /// - returns: A parser that parses _one_ or more occurrences of `self`,
    ///   separated and optionally ended by `separator`.
    func dividedBy1<Separator>(
        _ separator: GenericParser<StreamType, UserState, Separator>,
        endSeparatorRequired: Bool = true
    ) -> GenericParser<StreamType, UserState, [Result]> {
        if endSeparatorRequired {
            return (self <* separator).many1
        }

        return self >>- { result in
            // Type inference bug.
            let optionalSeparator: GenericParser<StreamType, UserState, [Result]> =
            separator >>- { _ in
                self.dividedBy(separator, endSeparatorRequired: false) >>- { results in
                    let allResults = results.prepending(result)
                    return GenericParser<StreamType, UserState, [Result]>(
                        result: allResults
                    )
                }
            }

            return optionalSeparator <|>
                GenericParser<StreamType, UserState, [Result]>(result: [result])
        }
    }

    /// Return a parser that parses `n` occurrences of `self`. If `n` is
    /// smaller or equal to zero, the parser returns `[]`. It returns an array
    /// of `n` values returned by `self`.
    ///
    /// - parameter n: The number of occurences of `self` to parse.
    /// - returns: A parser that parses `n` occurrences of `self`.
    func count(
        _ num: Int
    ) -> GenericParser<StreamType, UserState, [Result]> {
        func count(
            _ num: Int,
            results: [Result]
        ) -> GenericParser<StreamType, UserState, [Result]> {
            guard num > 0 else {
                return GenericParser<StreamType, UserState, [Result]>(
                    result: results
                )
            }

            return self >>- { result in
                let allResults = results.appending(result)
                return count(num - 1, results: allResults)
            }
        }

        return GenericParser<StreamType, UserState, [Result]> { state in
            return count(num, results: []).parse(state)
        }
    }

    /// Return a parser that parses _zero_ or more occurrences of `self`,
    /// separated by `oper`. Returns a value obtained by a _right_ associative
    /// application of all functions returned by `oper` to the values returned
    /// by `self`. If there are no occurrences of `self`, the value `otherwise`
    /// is returned.
    ///
    /// - parameters:
    ///   - oper: The operator parser.
    ///   - otherwise: Default value returned when there are no occurences of
    ///     `self`.
    /// - returns: A parser that parses _zero_ or more occurrences of `self`,
    ///   separated by `oper`.
    func chainRight(
        _ oper: GenericParser<StreamType, UserState, (Result, Result) -> Result>,
        otherwise: Result
    ) -> GenericParser {
        return chainRight1(oper) <|> GenericParser(result: otherwise)
    }

    /// Return a parser that parses _one_ or more occurrences of `self`,
    /// separated by `oper`. Returns a value obtained by a _right_ associative
    /// application of all functions returned by `op` to the values returned by
    /// `self`.
    ///
    /// - parameter oper: The operator parser.
    /// - returns: A parser that parses _one_ or more occurrences of `self`,
    ///   separated by `oper`.
    func chainRight1(
        _ oper: GenericParser<StreamType, UserState, (Result, Result) -> Result>
    ) -> GenericParser {
        func scan() -> GenericParser {
            return self >>- { result in rest(result) }
        }

        func rest(_ left: Result) -> GenericParser {
            // Type inference bug.
            let operParser: GenericParser = oper >>- { transform in
                scan() >>- { right in
                    let result = transform(left, right)
                    return GenericParser(result: result)
                }
            }

            return operParser <|> GenericParser(result: left)
        }

        return scan()
    }

    /// Return a parser that parses _zero_ or more occurrences of `self`,
    /// separated by `oper`. Returns a value obtained by a _left_ associative
    /// application of all functions returned by `oper` to the values returned
    /// by `self`. If there are zero occurrences of `self`, the value
    /// `otherwise` is returned.
    ///
    /// - parameters:
    ///   - oper: The operator parser.
    ///   - otherwise: Default value returned when there are no occurences of
    ///     `self`.
    /// - returns: A parser that parses _zero_ or more occurrences of `self`,
    ///   separated by `oper`.
    func chainLeft(
        _ oper: GenericParser<StreamType, UserState, (Result, Result) -> Result>,
        otherwise: Result
    ) -> GenericParser {
        return chainLeft1(oper) <|> GenericParser(result: otherwise)
    }

    /// Return a parser that parses _one_ or more occurrences of `self`,
    /// separated by oper`. Returns a value obtained by a _left_ associative
    /// application of all functions returned by `oper` to the values returned
    /// by `self`. This parser can for example be used to eliminate left
    /// recursion which typically occurs in expression grammars.
    ///
    ///     let addOp: GenericParser<String, (), (Int, Int) -> Int> =
    ///         StringParser.character("+") *> GenericParser(result: +) <|>
    ///         StringParser.character("-") *> GenericParser(result: -)
    ///
    ///     let expr = number.chainLeft1(addOp)
    ///
    /// - parameter oper: The operator parser.
    /// - returns: A parser that parses _one_ or more occurrences of `self`,
    ///   separated by `oper`.
    func chainLeft1(
        _ oper: GenericParser<StreamType, UserState, (Result, Result) -> Result>
    ) -> GenericParser {
        func rest(_ left: Result) -> GenericParser {
            let operParser = oper >>- { operatorParser in
                self >>- { right in rest(operatorParser(left, right)) }
            }

            return operParser <|> GenericParser(result: left)
        }

        return self >>- { result in rest(result) }
    }

    /// A parser that only succeeds when parser `self` fails. This parser does
    /// not consume any input. This parser can be used to implement the
    /// 'longest match' rule. For example, when recognizing keywords (for
    /// example `let`), we want to make sure that a keyword is not followed by a
    /// legal identifier character, in which case the keyword is actually an
    /// identifier (for example `lets`). We can program this behaviour as
    /// follows:
    ///
    ///     let alphaNum = StringParser.alphaNumeric
    ///     let keyworkLet = StringParser.string("let") <* alphaNum.noOccurence
    var noOccurence: GenericParser<StreamType, UserState, ()> {
        let selfAttempt = attempt >>- { result in
            GenericParser<StreamType, UserState, ()>.unexpected(
                String(reflecting: result)
            )
        }

        return (selfAttempt <|> GenericParser<StreamType, UserState, ()>(
            result: ())).attempt
    }

    /// Return a parser that applies parser `self` _zero_ or more times until
    /// parser `end` succeeds. Returns the list of values returned by `self`.
    /// This parser can be used to scan comments:
    ///
    ///     let anyChar = StringParser.anyCharacter
    ///     let start = StringParser.string("<!--")
    ///     let end = StringParser.string("-->")
    ///     let comment = start *> anyChar.manyTill(end.attempt)
    ///
    /// Note the overlapping parsers `anyChar` and `end`, and therefore the use
    /// of the 'attempt' combinator.
    ///
    /// - parameter end: End parser.
    /// - returns: A parser that applies parser `self` _zero_ or more times
    ///   until parser `end` succeeds.
    func manyTill<End>(
        _ end: GenericParser<StreamType, UserState, End>
    ) -> GenericParser<StreamType, UserState, [Result]> {
        func scan() -> GenericParser<StreamType, UserState, [Result]> {
            let empty = end *>
                GenericParser<StreamType, UserState, [Result]>(result: [])

            return empty <|> (self >>- { result in
                scan() >>- { results in
                    let allResults = results.prepending(result)
                    return GenericParser<StreamType, UserState, [Result]>(
                        result: allResults
                    )
                }
            })
        }

        return scan()
    }

    /// Return a recursive parser combined with itself. It can be used to parse
    /// nested expressions. As an exemple, an expression inside a pair of
    /// parentheses is itself an expression that can be nested inside another
    /// pair of parentheses.
    ///
    ///     let expression = GenericParser<...>.recursive { expression in
    ///         parentheses(expression) <|>
    ///         identifier <|>
    ///         legalOperator <|> ...
    ///
    /// - parameter combine: A function receiving a placeholder parser as
    ///   parameter that can be nested in other expressions.
    /// - returns: A recursive parser combined with itself.
    static func recursive(
        _ combine: (GenericParser) -> GenericParser
    ) -> GenericParser {
        var expression: GenericParser!
        let placeholder = GenericParser { expression }

        expression = combine(placeholder)

        return expression
    }
}

// ==============================================================================
// Extension containing methods related to special parsers.
public extension Parsec where StreamType.Iterator.Element == Result {
    /// A parser that accepts any kind of token. It is for example used to
    /// implement 'eof'. It returns the accepted token.
    static var anyToken: GenericParser<StreamType, UserState, Result> {
        return GenericParser.tokenPrimitive(
            tokenDescription: { String(reflecting: $0) },
            nextPosition: { pos, _ in pos },
            match: { $0 })
    }

    /// A parser that only succeeds at the end of the input. This is not a
    /// primitive parser but it is defined using `GenericParser.noOccurence`.
    ///
    /// - returns: A parser that only succeeds at the end of the input.
    static var eof: GenericParser<StreamType, UserState, ()> {
        return GenericParser.anyToken.noOccurence <?>
            LocalizedString("end of input")
    }
}
