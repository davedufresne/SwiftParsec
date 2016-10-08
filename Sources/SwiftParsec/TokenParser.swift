//==============================================================================
// TokenParser.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-10-05.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// A helper module to parse lexical elements (tokens). See the initializer for
// the `TokenParser` structure for a description of how to use it.
// Operator implementations for the `Message` type.
//==============================================================================

//==============================================================================
/// Types implementing this protocol hold lexical parsers.
public protocol TokenParser {
    
    /// The state supplied by the user.
    associatedtype UserState
    
    /// Language definition parameterizing the lexer.
    var languageDefinition: LanguageDefinition<UserState> { get }
    
    /// This lexeme parser parses a legal identifier. Returns the identifier
    /// string. This parser will fail on identifiers that are reserved words.
    /// Legal identifier (start) characters and reserved words are defined in
    /// the `LanguageDefinition` that is passed to the initializer of this token
    /// parser. An `identifier` is treated as a single token using
    /// `GenericParser.attempt`.
    var identifier: GenericParser<String, UserState, String> { get }
    
    /// The lexeme parser `reservedName(name)` parses `symbol(name)`, but it
    /// also checks that the `name` is not a prefix of a valid identifier. A
    /// _reserved_ word is treated as a single token using
    /// `GenericParser.attempt`.
    ///
    /// - parameter name: The reserved name to parse.
    /// - returns: A parser returning nothing.
    func reservedName(_ name: String) -> GenericParser<String, UserState, ()>
    
    /// This lexeme parser parses a legal operator and returns the name of the
    /// operator. This parser will fail on any operators that are reserved
    /// operators. Legal operator (start) characters and reserved operators are
    /// defined in the `LanguageDefinition` that is passed to the initializer of
    /// this token parser. An 'operator' is treated as a single token using
    /// `GenericParser.attempt`.
    var legalOperator: GenericParser<String, UserState, String> { get }
    
    /// The lexeme parser `reservedOperator(name)` parses `symbol(name)`, but it
    /// also checks that the `name` is not a prefix of a valid operator. A
    /// 'reservedOperator' is treated as a single token using
    /// `GenericParser.attempt`.
    ///
    /// - parameter name: The operator name.
    /// - returns: A parser returning nothing.
    func reservedOperator(
        _ name: String
    ) -> GenericParser<String, UserState, ()>
    
    /// This lexeme parser parses a single literal character and returns the
    /// literal character value. This parser deals correctly with escape
    /// sequences.
    var characterLiteral: GenericParser<String, UserState, Character> { get }
    
    /// This lexeme parser parses a literal string and returns the literal
    /// string value. This parser deals correctly with escape sequences and
    /// gaps.
    var stringLiteral: GenericParser<String, UserState, String> { get }
    
    /// This lexeme parser parses a natural number (a positive whole number) and
    /// returns the value of the number. The number can be specified in
    /// 'decimal', 'hexadecimal' or 'octal'.
    var natural: GenericParser<String, UserState, Int> { get }
    
    /// This lexeme parser parses an integer (a whole number). This parser is
    /// like `natural` except that it can be prefixed with sign (i.e. "-" or
    /// "+"). It returns the value of the number. The number can be specified in
    /// 'decimal', 'hexadecimal' or 'octal'.
    var integer: GenericParser<String, UserState, Int> { get }
    
    /// This lexeme parser parses an integer (a whole number). It is like
    /// `integer` except that it can parse bigger numbers. Returns the value of
    /// the number as a `Double`.
    var integerAsFloat: GenericParser<String, UserState, Double> { get }
    
    /// This lexeme parser parses a floating point value and returns the value
    /// of the number.
    var float: GenericParser<String, UserState, Double> { get }
    
    /// This lexeme parser parses either `integer` or a `float` and returns the
    /// value of the number. This parser deals with any overlap in the grammar
    /// rules for integers and floats.
    var number: GenericParser<String, UserState, Either<Int, Double>> { get }
    
    /// Parses a positive whole number in the decimal system. Returns the value
    /// of the number.
    static var decimal: GenericParser<String, UserState, Int> { get }
    
    /// Parses a positive whole number in the hexadecimal system. The number
    /// should be prefixed with "x" or "X". Returns the value of the number.
    static var hexadecimal: GenericParser<String, UserState, Int> { get }
    
    /// Parses a positive whole number in the octal system. The number should be
    /// prefixed with "o" or "O". Returns the value of the number.
    static var octal: GenericParser<String, UserState, Int> { get }
    
    /// Lexeme parser `symbol(str)` parses `str` and skips trailing white space.
    ///
    /// - parameter name: The name of the symbol to parse.
    /// - returns: `name`.
    func symbol(_ name: String) -> GenericParser<String, UserState, String>
    
    /// `lexeme(parser)` first applies `parser` and than the `whiteSpace`
    /// parser, returning the value of `parser`. Every lexical token (lexeme) is
    /// defined using `lexeme`, this way every parse starts at a point without
    /// white space. Parsers that use `lexeme` are called _lexeme_ parsers in
    /// this document.
    ///
    /// The only point where the 'whiteSpace' parser should be called explicitly
    /// is the start of the main parser in order to skip any leading white
    /// space.
    ///
    ///     let mainParser = sum <^> whiteSpace *> lexeme(digit) <* eof
    ///
    /// - parameter parser: The parser to transform in a 'lexeme'.
    /// - returns: The value of `parser`.
    func lexeme<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result>
    
    /// Parses any white space. White space consists of _zero_ or more
    /// occurrences of a 'space', a line comment or a block (multiline) comment.
    /// Block comments may be nested. How comments are started and ended is
    /// defined in the `LanguageDefinition` that is passed to the initializer of
    /// this token parser.
    var whiteSpace: GenericParser<String, UserState, ()> { get }
    
    /// Lexeme parser `parentheses(parser)` parses `parser` enclosed in
    /// parentheses, returning the value of `parser`.
    ///
    /// - parameter parser: The parser applied between the parentheses.
    /// - returns: The value of `parser`.
    func parentheses<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result>
    
    /// Lexeme parser `braces(parser)` parses `parser` enclosed in braces "{"
    /// and "}", returning the value of `parser`.
    ///
    /// - parameter parser: The parser applied between the braces.
    /// - returns: The value of `parser`.
    func braces<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result>
    
    /// Lexeme parser `angles(parser)` parses `parser` enclosed in angle
    /// brackets "<" and ">", returning the value of `parser`.
    ///
    /// - parameter parser: The parser applied between the angles.
    /// - returns: The value of `parser`.
    func angles<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result>
    
    /// Lexeme parser `brackets(parser)` parses `parser` enclosed in brackets
    /// "[" and "]", returning the value of `parser`.
    ///
    /// - parameter parser: The parser applied between the brackets.
    /// - returns: The value of `parser`.
    func brackets<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result>
    
    /// Lexeme parser `semicolon` parses the character ";" and skips any
    /// trailing white space. Returns the string ";".
    var semicolon: GenericParser<String, UserState, String> { get }
    
    /// Lexeme parser `comma` parses the character "," and skips any trailing
    /// white space. Returns the string ",".
    var comma: GenericParser<String, UserState, String> { get }
    
    /// Lexeme parser `colon` parses the character ":" and skips any trailing
    /// white space. Returns the string ":".
    var colon: GenericParser<String, UserState, String> { get }
    
    /// Lexeme parser `dot` parses the character "." and skips any trailing
    /// white space. Returns the string ".".
    var dot: GenericParser<String, UserState, String> { get }
    
    /// Lexeme parser `semicolonSeperated(parser)` parses _zero_ or more
    /// occurrences of `parser` separated by `semicolon`. Returns an array of
    /// values returned by `parser`.
    ///
    /// - parameter parser: The parser applied between semicolons.
    /// - returns: An array of values returned by `parser`.
    func semicolonSeparated<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, [Result]>
    
    /// Lexeme parser `semicolonSeperated1(parser)` parses _one_ or more
    /// occurrences of `parser` separated by `semicolon`. Returns an array of
    /// values returned by `parser`.
    ///
    /// - parameter parser: The parser applied between semicolons.
    /// - returns: An array of values returned by `parser`.
    func semicolonSeparated1<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, [Result]>
    
    /// Lexeme parser `commaSeparated(parser)` parses _zero_ or more occurrences
    /// of `parser` separated by `comma`. Returns an array of values returned by
    /// `parser`.
    ///
    /// - parameter parser: The parser applied between commas.
    /// - returns: An array of values returned by `parser`.
    func commaSeparated<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, [Result]>
    
    /// Lexeme parser `commaSeparated1(parser)` parses _one_ or more occurrences
    /// of `parser` separated by `comma`. Returns an array of values returned by
    /// `parser`.
    ///
    /// - parameter parser: The parser applied between commas.
    /// - returns: An array of values returned by `parser`.
    func commaSeparated1<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, [Result]>
    
}
