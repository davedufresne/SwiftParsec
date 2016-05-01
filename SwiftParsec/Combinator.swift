//
//  Combinator.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-26.
//  Copyright © 2015 David Dufresne. All rights reserved.
//
// Commonly used generic combinators
//

import Foundation

public extension GenericParser {
    
    /// Return a parser that tries to apply the parsers in the array `parsers` in order, until one of them succeeds. It returns the value of the succeeding parser.
    ///
    /// - parameter parsers: An array of parsers to try.
    /// - returns: A parser that tries to apply the parsers in the array `parsers` in order, until one of them succeeds.
    public static func choice<S: SequenceType where S.Generator.Element == GenericParser>(parsers: S) -> GenericParser {
        
        return parsers.reduce(GenericParser.empty, combine: <|>)
        
    }
    
    /// A parser that tries to apply `self`. If `self` fails without consuming input, it returns `nil`, otherwise it returns the value returned by `self`.
    public var optional: GenericParser<Stream, UserState, Result?> {
        
        return map({ $0 }).otherwise(nil)
        
    }
    
    /// Return a parser that tries to apply `self`. If `self` fails without consuming input, it returns `result`, or else the value returned by `self`.
    ///
    /// - parameter result: The result to return if `self` fails without consuming input.
    /// - returns: A parser that tries to apply `self`. If `self` fails without consuming input, it returns `result`.
    public func otherwise(result: Result) -> GenericParser {
        
        return self <|> GenericParser(result: result)
        
    }
    
    /// A parser that tries to apply `self`. It will parse `self` or nothing. It only fails if `self` fails after consuming input. It discards the result of `self`.
    public var discard: GenericParser<Stream, UserState, ()> {
        
        return map { _ in () } <|> GenericParser<Stream, UserState, ()>(result: ())
        
    }
    
    /// Return a parser that parses `opening`, followed by `self` and `closing`. It returns the value returned by `self`.
    ///
    /// - parameters:
    ///   - opening: The first parser to apply.
    ///   - closing: The last parser to apply.
    /// - returns: A parser that parses `opening`, followed by `self` and `closing`.
    public func between<U, V>(opening: GenericParser<Stream, UserState, U>, _ closing: GenericParser<Stream, UserState, V>) -> GenericParser {
        
        return opening *> self <* closing
        
    }
    
    /// A parser that applies `self` _one_ or more times, skipping its result.
    public var skipMany1: GenericParser<Stream, UserState, ()> {
        
        return self >>- { _ in self.skipMany }
        
    }
    
    /// A parser that applies `self` _one_ or more times. It returns an array of the returned values of `self`.
    ///
    ///     let word = StringParser.letter.many1
    public var many1: GenericParser<Stream, UserState, [Result]> {
        
        return self >>- { result in
            
            self.many >>- { results in
                
                let rs = results.prepending(result)
                return GenericParser<Stream, UserState, [Result]>(result: rs)
                
            }
            
        }
        
    }
    
    /// Return a parser that parses _zero_ or more occurrences of `self`, separated by `separator`. It returns an array of values returned by `self`.
    ///
    ///     let comma = StringParser.character(",")
    ///     let letter = StringParser.letter
    ///     let commaSeparated = letter.separatedBy(comma)
    ///
    /// - parameter separator: The separator parser.
    /// - returns: A parser that parses _zero_ or more occurrences of `self`, separated by `separator`.
    public func separatedBy<Separator>(separator: GenericParser<Stream, UserState, Separator>) -> GenericParser<Stream, UserState, [Result]> {
        
        return separatedBy1(separator) <|> GenericParser<Stream, UserState, [Result]>(result: [])
        
    }
    
    /// Return a parser that parses _one_ or more occurrences of `self`, separated by `separator`. It returns an array of values returned by `self`.
    ///
    /// - parameter separator: The separator parser.
    /// - returns: A parser that parses _one_ or more occurrences of `self`, separated by `separator`.
    public func separatedBy1<Separator>(separator: GenericParser<Stream, UserState, Separator>) -> GenericParser<Stream, UserState, [Result]> {
        
        return self >>- { result in
            
            (separator *> self).many >>- { results in
                
                let rs = results.prepending(result)
                return GenericParser<Stream, UserState, [Result]>(result: rs)
                
            }
            
        }
        
    }
    
    /// Return a parser that parses _zero_ or more occurrences of `self`, separated and optionally ended by `separator`. It returns an array of values returned by `self`.
    ///
    ///     let cStatements = cStatement.dividedBy(semicolon)
    ///
    ///     let swiftStatements = swiftStatement.dividedBy(semicolon, endSeparatorRequired: false)
    ///
    /// - parameters:
    ///   - separator: The separator parser.
    ///   - endSeparatorRequired: Indicates if the separator is required at the end. The default value is true.
    /// - returns: A parser that parses _zero_ or more occurrences of `self`, separated and optionally ended by `separator`.
    public func dividedBy<Separator>(separator: GenericParser<Stream, UserState, Separator>, endSeparatorRequired: Bool = true) -> GenericParser<Stream, UserState, [Result]> {
        
        if endSeparatorRequired {
            
            return (self <* separator).many
            
        }
        
        return dividedBy1(separator, endSeparatorRequired: false) <|>
            GenericParser<Stream, UserState, [Result]>(result: [])
        
    }
    
    /// Return a parser that parses _one_ or more occurrences of `self`, separated and optionally ended by `separator`. It returns an array of values returned by `self`.
    ///
    /// - parameters:
    ///   - separator: The separator parser.
    ///   - endSeparatorRequired: Indicates if the separator is required at the end. The default value is true.
    /// - returns: A parser that parses _one_ or more occurrences of `self`, separated and optionally ended by `separator`.
    public func dividedBy1<Separator>(separator: GenericParser<Stream, UserState, Separator>, endSeparatorRequired: Bool = true) -> GenericParser<Stream, UserState, [Result]> {
        
        if endSeparatorRequired {
            
            return (self <* separator).many1
            
        }
        
        return self >>- { result in
            
            // Type inference bug.
            let optionalSeparator: GenericParser<Stream, UserState, [Result]> =
            separator >>- { _ in
                
                self.dividedBy(separator, endSeparatorRequired: false) >>- { results in
                    
                    let rs = results.prepending(result)
                    return GenericParser<Stream, UserState, [Result]>(result: rs)
                    
                }
                
            }
            
            return optionalSeparator <|> GenericParser<Stream, UserState, [Result]>(result: [result])
            
        }
        
    }
    
    /// Return a parser that parses `n` occurrences of `self`. If `n` is smaller or equal to zero, the parser returns `[]`. It returns an array of `n` values returned by `self`.
    ///
    /// - parameter n: The number of occurences of `self` to parse.
    /// - returns: A parser that parses `n` occurrences of `self`.
    public func count(n: Int) -> GenericParser<Stream, UserState, [Result]> {
        
        func count(n: Int, results: [Result]) -> GenericParser<Stream, UserState, [Result]> {
            
            guard n > 0 else {
                
                return GenericParser<Stream, UserState, [Result]>(result: results)
                
            }
            
            return self >>- { result in
                
                let rs = results.appending(result)
                return count(n - 1, results: rs)
                
            }
            
        }
        
        return GenericParser<Stream, UserState, [Result]> { state in
            
            return count(n, results: []).parse(state: state)
            
        }
        
    }
    
    /// Return a parser that parses _zero_ or more occurrences of `self`, separated by `oper`. Returns a value obtained by a _right_ associative application of all functions returned by `oper` to the values returned by `self`. If there are no occurrences of `self`, the value `otherwise` is returned.
    ///
    /// - parameters:
    ///   - oper: The operator parser.
    ///   - otherwise: Default value returned when there are no occurences of `self`.
    /// - returns: A parser that parses _zero_ or more occurrences of `self`, separated by `oper`.
    public func chainRight(oper: GenericParser<Stream, UserState, (Result, Result) -> Result>, otherwise: Result) -> GenericParser {
    
        return chainRight1(oper) <|> GenericParser(result: otherwise)
        
    }
    
    /// Return a parser that parses _one_ or more occurrences of `self`, separated by `oper`. Returns a value obtained by a _right_ associative application of all functions returned by `op` to the values returned by `self`.
    ///
    /// - parameter oper: The operator parser.
    /// - returns: A parser that parses _one_ or more occurrences of `self`, separated by `oper`.
    public func chainRight1(oper: GenericParser<Stream, UserState, (Result, Result) -> Result>) -> GenericParser {
        
        func scan() -> GenericParser {
            
            return self >>- { result in rest(result) }
            
        }
        
        func rest(left: Result) -> GenericParser {
            
            // Type inference bug.
            let operParser: GenericParser = oper >>- { op in
                
                scan() >>- { right in
                    
                    let result = op(left, right)
                    return GenericParser(result: result)
                    
                }
                
            }
            
            return operParser <|> GenericParser(result: left)
            
        }
        
        return scan()
        
    }
    
    /// Return a parser that parses _zero_ or more occurrences of `self`, separated by `oper`. Returns a value obtained by a _left_ associative application of all functions returned by `oper` to the values returned by `self`. If there are zero occurrences of `self`, the value `otherwise` is returned.
    ///
    /// - parameters:
    ///   - oper: The operator parser.
    ///   - otherwise: Default value returned when there are no occurences of `self`.
    /// - returns: A parser that parses _zero_ or more occurrences of `self`, separated by `oper`.
    public func chainLeft(oper: GenericParser<Stream, UserState, (Result, Result) -> Result>, otherwise: Result) -> GenericParser {
        
        return chainLeft1(oper) <|> GenericParser(result: otherwise)
        
    }
    
    /// Return a parser that parses _one_ or more occurrences of `self`, separated by oper`. Returns a value obtained by a _left_ associative application of all functions returned by `oper` to the values returned by `self`. This parser can for example be used to eliminate left recursion which typically occurs in expression grammars.
    ///
    ///     let addOp: GenericParser<String, (), (Int, Int) -> Int> =
    ///         StringParser.character("+") *> GenericParser(result: +) <|>
    ///         StringParser.character("-") *> GenericParser(result: -)
    ///
    ///     let expr = number.chainLeft1(addOp)
    ///
    /// - parameter oper: The operator parser.
    /// - returns: A parser that parses _one_ or more occurrences of `self`, separated by `oper`.
    public func chainLeft1(oper: GenericParser<Stream, UserState, (Result, Result) -> Result>) -> GenericParser {
        
        func rest(left: Result) -> GenericParser {
            
            let operParser = oper >>- { op in
                
                self >>- { right in rest(op(left, right)) }
                
            }
            
            return operParser <|> GenericParser(result: left)
            
        }
        
        return self >>- { result in rest(result) }
        
    }
    
    /// A parser that only succeeds when parser `self` fails. This parser does not consume any input. This parser can be used to implement the 'longest match' rule. For example, when recognizing keywords (for example `let`), we want to make sure that a keyword is not followed by a legal identifier character, in which case the keyword is actually an identifier (for example `lets`). We can program this behaviour as follows:
    ///
    ///     let alphaNum = StringParser.alphaNumeric
    ///     let keyworkLet = StringParser.string("let") <* alphaNum.noOccurence
    public var noOccurence: GenericParser<Stream, UserState, ()> {
        
        let selfAttempt = attempt >>- { result in
            
            GenericParser<Stream, UserState, ()>.unexpected(String(reflecting: result))
            
        }
        
        return (selfAttempt <|> GenericParser<Stream, UserState, ()>(result: ())).attempt
        
    }
    
    /// Return a parser that applies parser `self` _zero_ or more times until parser `end` succeeds. Returns the list of values returned by `self`. This parser can be used to scan comments:
    ///
    ///     let anyChar = StringParser.anyCharacter
    ///     let start = StringParser.string("<!--")
    ///     let end = StringParser.string("-->")
    ///     let comment = start *> anyChar.manyTill(end.attempt)
    ///
    /// Note the overlapping parsers `anyChar` and `end`, and therefore the use of the 'attempt' combinator.
    ///
    /// - parameter end: End parser.
    /// - returns: A parser that applies parser `self` _zero_ or more times until parser `end` succeeds.
    public func manyTill<End>(end: GenericParser<Stream, UserState, End>) -> GenericParser<Stream, UserState, [Result]> {
        
        func scan() -> GenericParser<Stream, UserState, [Result]> {
            
            let empty = end *> GenericParser<Stream, UserState, [Result]>(result: [])
            
            return empty <|> (self >>- { result in
                
                scan() >>- { results in
                    
                    let rs = results.prepending(result)
                    return GenericParser<Stream, UserState, [Result]>(result: rs)
                    
                }
                
            })
            
        }
        
        return scan()
        
    }
    
    /// Return a recursive parser combined with itself. It can be used to parse nested expressions. As an exemple, an expression inside a pair of parentheses is itself an expression that can be nested inside another pair of parentheses.
    ///
    ///     let expression = GenericParser<...>.recursive { expression in
    ///         parentheses(expression) <|>
    ///         identifier <|>
    ///         legalOperator <|> ...
    ///
    /// - parameter combine: A function receiving a placeholder parser as parameter that can be nested in other expressions.
    /// - returns: A recursive parser combined with itself.
    public static func recursive(@noescape combine: GenericParser -> GenericParser) -> GenericParser {
        
        var expression: GenericParser!
        let placeholder = GenericParser { expression }
        
        expression = combine(placeholder)
        
        return expression
        
    }
    
}

public extension ParsecType where Stream.Element == Result {
    
    /// A parser that accepts any kind of token. It is for example used to implement 'eof'. It returns the accepted token.
    public static var anyToken: GenericParser<Stream, UserState, Result> {
        
        return GenericParser.tokenPrimitive(
            tokenDescription: { String(reflecting: $0) },
            nextPosition: { pos, _, _ in pos },
            match: { $0 })
        
    }
    
    /// A parser that only succeeds at the end of the input. This is not a primitive parser but it is defined using `GenericParser.noOccurence`.
    ///
    /// - returns: A parser that only succeeds at the end of the input.
    public static var eof: GenericParser<Stream, UserState, ()> {
        
        return GenericParser.anyToken.noOccurence <?> NSLocalizedString("end of input", comment: "Parser combinators.")
        
    }
    
}
