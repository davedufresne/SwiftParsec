// ==============================================================================
// TokenParser.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-10-05.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// A helper module to parse lexical elements (tokens). See the initializer for
// the `TokenParser` structure for a description of how to use it.
// Operator implementations for the `Message` type.
// ==============================================================================
// swiftlint:disable file_length

import func Foundation.pow

// ==============================================================================
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

// Default implementation of the methods of the `TokenParser` parser type.
extension TokenParser {
    // Type aliases used internally to simplify the code.
    typealias StrParser = GenericParser<String, UserState, String>
    typealias CharacterParser = GenericParser<String, UserState, Character>
    typealias IntParser = GenericParser<String, UserState, Int>
    typealias DoubleParser = GenericParser<String, UserState, Double>
    typealias IntDoubleParser =
        GenericParser<String, UserState, Either<Int, Double>>
    typealias VoidParser = GenericParser<String, UserState, ()>

    //
    // Identifiers & Reserved words
    //

    /// This lexeme parser parses a legal identifier. Returns the identifier
    /// string. This parser will fail on identifiers that are reserved words.
    /// Legal identifier (start) characters and reserved words are defined in
    /// the `LanguageDefinition` that is passed to the initializer of this token
    /// parser. An `identifier` is treated as a single token using
    /// `GenericParser.attempt`.
    public var identifier: GenericParser<String, UserState, String> {
        let langDef = languageDefinition

        let ident: StrParser = langDef.identifierStart >>- { char in
            langDef.identifierLetter(char).many >>- { chars in
                let allChars = chars.prepending(char)
                return GenericParser(result: String(allChars))
            }
        } <?> LocalizedString("identifier")

        let identCheck: StrParser = ident >>- { name in
            let reservedNames: Set<String>
            let identifierName: String

            if langDef.isCaseSensitive {
                reservedNames = langDef.reservedNames
                identifierName = name
            } else {
                reservedNames = langDef.reservedNames.map { $0.lowercased() }
                identifierName = name.lowercased()
            }

            guard !reservedNames.contains(identifierName) else {
                let reservedWordMsg = LocalizedString("reserved word ")
                return GenericParser.unexpected(reservedWordMsg + name)
            }

            return GenericParser(result: name)
        }

        return lexeme(identCheck.attempt)
    }

    /// The lexeme parser `reservedName(name)` parses `symbol(name)`, but it
    /// also checks that the `name` is not a prefix of a valid identifier. A
    /// _reserved_ word is treated as a single token using
    /// `GenericParser.attempt`.
    ///
    /// - parameter name: The reserved name to parse.
    /// - returns: A parser returning nothing.
    public func reservedName(
        _ name: String
    ) -> GenericParser<String, UserState, ()> {
        let lastChar = name.last!
        let reserved = caseString(name) *>
            languageDefinition.identifierLetter(lastChar).noOccurence <?>
            LocalizedString("end of ") + name

        return lexeme(reserved.attempt)
    }

    //
    // Operators & reserved operators
    //

    /// This lexeme parser parses a legal operator and returns the name of the
    /// operator. This parser will fail on any operators that are reserved
    /// operators. Legal operator (start) characters and reserved operators are
    /// defined in the `LanguageDefinition` that is passed to the initializer of
    /// this token parser. An 'operator' is treated as a single token using
    /// `GenericParser.attempt`.
    public var legalOperator: GenericParser<String, UserState, String> {
        let langDef = languageDefinition

        let operatorParser: StrParser = langDef.operatorStart >>- { char in
            langDef.operatorLetter.many >>- { chars in
                let allChars = chars.prepending(char)
                return GenericParser(result: String(allChars))
            }
        } <?> LocalizedString("operator")

        let opCheck: StrParser = operatorParser >>- { name in
            guard !langDef.reservedOperators.contains(name) else {
                let reservedOperatorMsg = LocalizedString("reserved operator ")
                return GenericParser.unexpected(reservedOperatorMsg + name)
            }

            return GenericParser(result: name)
        }

        return lexeme(opCheck.attempt)
    }

    /// The lexeme parser `reservedOperator(name)` parses `symbol(name)`, but it
    /// also checks that the `name` is not a prefix of a valid operator. A
    /// 'reservedOperator' is treated as a single token using
    /// `GenericParser.attempt`.
    ///
    /// - parameter name: The operator name.
    /// - returns: A parser returning nothing.
    public func reservedOperator(
        _ name: String
    ) -> GenericParser<String, UserState, ()> {
        let operatorParser = VoidParser.string(name) *>
            languageDefinition.operatorLetter.noOccurence <?>
            LocalizedString("end of ") + name

        return lexeme(operatorParser.attempt)
    }

    //
    // Characters & Strings
    //

    /// This lexeme parser parses a single literal character and returns the
    /// literal character value. This parser deals correctly with escape
    /// sequences.
    public var characterLiteral: GenericParser<String, UserState, Character> {
        let characterLetter = CharacterParser.satisfy { char in
            char != "'" && char != "\\" && char != substituteCharacter
        }

        let defaultCharEscape = GenericParser.character("\\") *>
            GenericTokenParser<UserState>.escapeCode
        let characterEscape =
            languageDefinition.characterEscape ?? defaultCharEscape

        let character = characterLetter <|> characterEscape <?>
            LocalizedString("literal character")

        let quote = CharacterParser.character("'")

        let endOfCharMsg = LocalizedString("end of character")

        return lexeme(character.between(quote, quote <?> endOfCharMsg)) <?>
            LocalizedString("character")
    }

    /// This lexeme parser parses a literal string and returns the literal
    /// string value. This parser deals correctly with escape sequences and
    /// gaps.
    public var stringLiteral: GenericParser<String, UserState, String> {
        let stringLetter = CharacterParser.satisfy { char in
            char != "\"" && char != "\\" && char != substituteCharacter
        }

        let escapeGap: GenericParser<String, UserState, Character?> =
            GenericParser.space.many1 *> GenericParser.character("\\") *>
                GenericParser(result: nil) <?>
                LocalizedString("end of string gap")

        let escapeEmpty: GenericParser<String, UserState, Character?> =
            GenericParser.character("&") *> GenericParser(result: nil)

        let characterEscape: GenericParser<String, UserState, Character?> =
            GenericParser.character("\\") *>
                (escapeGap <|> escapeEmpty <|>
                GenericTokenParser.escapeCode.map { $0 })

        let stringEscape =
            languageDefinition.characterEscape?.map { $0 } ?? characterEscape

        let stringChar = stringLetter.map { $0 } <|> stringEscape

        let doubleQuote = CharacterParser.character("\"")
        let endOfStringMsg = LocalizedString("end of string")
        let string = stringChar.many.between(
            doubleQuote, doubleQuote <?> endOfStringMsg
        )

        let literalString = string.map({ str in
            str.reduce("") { (acc, char) in
                guard let char = char else { return acc }

                return acc.appending(char)
            }
        }) <?> LocalizedString("literal string")

        return lexeme(literalString)
    }

    //
    // Numbers
    //

    /// This lexeme parser parses a natural number (a positive whole number) and
    /// returns the value of the number. The number can be specified in
    /// 'decimal', 'hexadecimal' or 'octal'.
    public var natural: GenericParser<String, UserState, Int> {
        return lexeme(GenericTokenParser.naturalNumber) <?>
            LocalizedString("natural")
    }

    /// This lexeme parser parses an integer (a whole number). This parser is
    /// like `natural` except that it can be prefixed with sign (i.e. "-" or
    /// "+"). It returns the value of the number. The number can be specified in
    /// 'decimal', 'hexadecimal' or 'octal'.
    public var integer: GenericParser<String, UserState, Int> {
        let int = lexeme(GenericTokenParser.sign()) >>- { transform in
            GenericTokenParser.naturalNumber >>- {
                GenericParser(result: transform($0))
            }
        }

        return lexeme(int) <?> LocalizedString("integer")
    }

    /// This lexeme parser parses an integer (a whole number). It is like
    /// `integer` except that it can parse bigger numbers. Returns the value of
    /// the number as a `Double`.
    public var integerAsFloat: GenericParser<String, UserState, Double> {
        let hexaPrefix = CharacterParser.oneOf(hexadecimalPrefixes)
        let hexa = hexaPrefix *> GenericTokenParser.doubleWithBase(
            16,
            parser: GenericParser.hexadecimalDigit
        )

        let octPrefix = CharacterParser.oneOf(octalPrefixes)
        let oct = octPrefix *> GenericTokenParser.doubleWithBase(
            8,
            parser: GenericParser.octalDigit
        )

        let decDigit = CharacterParser.decimalDigit
        let dec = GenericTokenParser.doubleWithBase(10, parser: decDigit)

        let zeroNumber = (GenericParser.character("0") *>
            (hexa <|> oct <|> dec <|> GenericParser(result: 0))) <?> ""

        let nat = zeroNumber <|> dec

        let double = lexeme(GenericTokenParser.sign()) >>- { sign in
            nat >>- { GenericParser(result: sign($0)) }
        }

        return lexeme(double) <?> LocalizedString("integer")
    }

    /// This lexeme parser parses a floating point value and returns the value
    /// of the number.
    public var float: GenericParser<String, UserState, Double> {
        let intPart = GenericTokenParser<UserState>.doubleIntegerPart
        let expPart = GenericTokenParser<UserState>.fractionalExponent
        let combinator = intPart >>- { expPart($0) }

        let double = lexeme(GenericTokenParser.sign()) >>- { sign in
            combinator >>- { GenericParser(result: sign($0)) }
        }

        return lexeme(double) <?> LocalizedString("float")
    }

    /// This lexeme parser parses either `integer` or a `float` and returns the
    /// value of the number. This parser deals with any overlap in the grammar
    /// rules for integers and floats.
    public var number: GenericParser<String, UserState, Either<Int, Double>> {
        let intDouble = float.map({ Either.right($0) }).attempt <|>
            integer.map({ Either.left($0) })

        return lexeme(intDouble) <?> LocalizedString("number")
    }

    /// Parses a positive whole number in the decimal system. Returns the value
    /// of the number.
    public static var decimal: GenericParser<String, UserState, Int> {
        return numberWithBase(10, parser: GenericParser.decimalDigit)
    }

    /// Parses a positive whole number in the hexadecimal system. The number
    /// should be prefixed with "x" or "X". Returns the value of the number.
    public static var hexadecimal: GenericParser<String, UserState, Int> {
        return GenericParser.oneOf(hexadecimalPrefixes) *>
            numberWithBase(16, parser: GenericParser.hexadecimalDigit)
    }

    /// Parses a positive whole number in the octal system. The number should be
    /// prefixed with "o" or "O". Returns the value of the number.
    public static var octal: GenericParser<String, UserState, Int> {
        return GenericParser.oneOf(octalPrefixes) *>
            numberWithBase(8, parser: GenericParser.octalDigit)
    }

    //
    // White space & symbols
    //

    /// Lexeme parser `symbol(str)` parses `str` and skips trailing white space.
    ///
    /// - parameter name: The name of the symbol to parse.
    /// - returns: `name`.
    public func symbol(
        _ name: String
    ) -> GenericParser<String, UserState, String> {
        return lexeme(StrParser.string(name))
    }

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
    public func lexeme<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result> {
        return parser <* whiteSpace
    }

    /// Parses any white space. White space consists of _zero_ or more
    /// occurrences of a 'space', a line comment or a block (multiline) comment.
    /// Block comments may be nested. How comments are started and ended is
    /// defined in the `LanguageDefinition` that is passed to the initializer of
    /// this token parser.
    public var whiteSpace: GenericParser<String, UserState, ()> {
        let simpleSpace = CharacterParser.satisfy({ $0.isSpace }).skipMany1

        let commentLineEmpty = languageDefinition.commentLine.isEmpty
        let commentStartEmpty = languageDefinition.commentStart.isEmpty

        if commentLineEmpty && commentStartEmpty {
            return (simpleSpace <?> "").skipMany
        }

        if commentLineEmpty {
            return (simpleSpace <|> multiLineComment <?> "").skipMany
        }

        if commentStartEmpty {
            return (simpleSpace <|> oneLineComment <?> "").skipMany
        }

        return (
            simpleSpace <|> oneLineComment <|> multiLineComment <?> ""
        ).skipMany
    }

    //
    // Bracketing
    //

    /// Lexeme parser `parentheses(parser)` parses `parser` enclosed in
    /// parentheses, returning the value of `parser`.
    ///
    /// - parameter parser: The parser applied between the parentheses.
    /// - returns: The value of `parser`.
    public func parentheses<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result> {
        return parser.between(symbol("("), symbol(")"))
    }

    /// Lexeme parser `braces(parser)` parses `parser` enclosed in braces "{"
    /// and "}", returning the value of `parser`.
    ///
    /// - parameter parser: The parser applied between the braces.
    /// - returns: The value of `parser`.
    public func braces<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result> {
        return parser.between(symbol("{"), symbol("}"))
    }

    /// Lexeme parser `angles(parser)` parses `parser` enclosed in angle
    /// brackets "<" and ">", returning the value of `parser`.
    ///
    /// - parameter parser: The parser applied between the angles.
    /// - returns: The value of `parser`.
    public func angles<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result> {
        return parser.between(symbol("<"), symbol(">"))
    }

    /// Lexeme parser `brackets(parser)` parses `parser` enclosed in brackets
    /// "[" and "]", returning the value of `parser`.
    ///
    /// - parameter parser: The parser applied between the brackets.
    /// - returns: The value of `parser`.
    public func brackets<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, Result> {
        return parser.between(symbol("["), symbol("]"))
    }

    /// Lexeme parser `semicolon` parses the character ";" and skips any
    /// trailing white space. Returns the string ";".
    public var semicolon: GenericParser<String, UserState, String> {
        return symbol(";")
    }

    /// Lexeme parser `comma` parses the character "," and skips any trailing
    /// white space. Returns the string ",".
    public var comma: GenericParser<String, UserState, String> {
        return symbol(",")
    }

    /// Lexeme parser `colon` parses the character ":" and skips any trailing
    /// white space. Returns the string ":".
    public var colon: GenericParser<String, UserState, String> {
        return symbol(":")
    }

    /// Lexeme parser `dot` parses the character "." and skips any trailing
    /// white space. Returns the string ".".
    public var dot: GenericParser<String, UserState, String> {
        return symbol(".")
    }

    /// Lexeme parser `semicolonSeperated(parser)` parses _zero_ or more
    /// occurrences of `parser` separated by `semicolon`. Returns an array of
    /// values returned by `parser`.
    ///
    /// - parameter parser: The parser applied between semicolons.
    /// - returns: An array of values returned by `parser`.
    public func semicolonSeparated<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, [Result]> {
        return parser.separatedBy(semicolon)
    }

    /// Lexeme parser `semicolonSeperated1(parser)` parses _one_ or more
    /// occurrences of `parser` separated by `semicolon`. Returns an array of
    /// values returned by `parser`.
    ///
    /// - parameter parser: The parser applied between semicolons.
    /// - returns: An array of values returned by `parser`.
    public func semicolonSeparated1<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, [Result]> {
        return parser.separatedBy1(semicolon)
    }

    /// Lexeme parser `commaSeparated(parser)` parses _zero_ or more occurrences
    /// of `parser` separated by `comma`. Returns an array of values returned by
    /// `parser`.
    ///
    /// - parameter parser: The parser applied between commas.
    /// - returns: An array of values returned by `parser`.
    public func commaSeparated<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, [Result]> {
        return parser.separatedBy(comma)
    }

    /// Lexeme parser `commaSeparated1(parser)` parses _one_ or more occurrences
    /// of `parser` separated by `comma`. Returns an array of values returned by
    /// `parser`.
    ///
    /// - parameter parser: The parser applied between commas.
    /// - returns: An array of values returned by `parser`.
    public func commaSeparated1<Result>(
        _ parser: GenericParser<String, UserState, Result>
    ) -> GenericParser<String, UserState, [Result]> {
        return parser.separatedBy1(comma)
    }

    //
    // Private methods. They sould be in a separate private extension but it
    // causes problems with the internal typealiases.
    //

    private var oneLineComment: VoidParser {
        let commentStart = StrParser.string(languageDefinition.commentLine)

        return commentStart.attempt *>
            GenericParser.satisfy({ $0 != "\n" }).skipMany *>
            GenericParser(result: ())
    }

    private var multiLineComment: VoidParser {
        return GenericParser {
            let commentStart =
                StrParser.string(self.languageDefinition.commentStart)

            return commentStart.attempt *> self.inComment
        }
    }

    private var inComment: VoidParser {
        return languageDefinition.allowNestedComments ?
            inNestedComment : inNonNestedComment
    }

    private var inNestedComment: VoidParser {
        return GenericParser {
            let langDef = self.languageDefinition

            let startEnd = (
                langDef.commentStart + langDef.commentEnd
                ).removingDuplicates()
            let commentEnd = StrParser.string(langDef.commentEnd)

            return commentEnd.attempt *> GenericParser(result: ()) <|>
                self.multiLineComment *> self.inNestedComment <|>
                GenericParser.noneOf(String(startEnd)).skipMany1 *>
                self.inNestedComment <|>
                GenericParser.oneOf(String(startEnd)) *>
                self.inNestedComment <?>
                LocalizedString("end of comment")
        }
    }

    private var inNonNestedComment: VoidParser {
        return GenericParser {
            let langDef = self.languageDefinition

            let startEnd = (
                langDef.commentStart + langDef.commentEnd
            ).removingDuplicates()
            let commentEnd = StrParser.string(langDef.commentEnd)

            return commentEnd.attempt *> GenericParser(result: ()) <|>
                GenericParser.noneOf(String(startEnd)).skipMany1 *>
                self.inNonNestedComment <|>
                GenericParser.oneOf(String(startEnd)) *>
                self.inNonNestedComment <?>
                LocalizedString("end of comment")
        }
    }

    private static var escapeCode: CharacterParser {
        return charEscape <|> charNumber <|> charAscii <|> charControl <?>
            LocalizedString("escape code")
    }

    private static var charEscape: CharacterParser {
        let parsers = escapeMap.map { escCode in
            CharacterParser.character(escCode.esc) *>
                GenericParser(result: escCode.code)
        }

        return GenericParser.choice(parsers)
    }

    private static var charNumber: CharacterParser {
        let octalDigit = CharacterParser.octalDigit
        let hexaDigit = CharacterParser.hexadecimalDigit

        let num = decimal <|>
            GenericParser.character("o") *>
            numberWithBase(8, parser: octalDigit) <|>
            GenericParser.character("x") *>
            numberWithBase(16, parser: hexaDigit)

        return num >>- { characterFromInt($0) }
    }

    private static var charAscii: CharacterParser {
        let parsers = asciiCodesMap.map { control in
            StrParser.string(control.esc) *> GenericParser(result: control.code)
        }

        return GenericParser.choice(parsers)
    }

    private static var charControl: CharacterParser {
        let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let ctrlCodes: CharacterParser =
            GenericParser.oneOf(upper).flatMap { char in
                let charA: Character = "A"
                let value = char.unicodeScalar.value -
                    charA.unicodeScalar.value + 1
                let unicode = UnicodeScalar.fromUInt32(value)!

                return GenericParser(result: Character(unicode))
            }

        return GenericParser.character("^") *> (ctrlCodes <|>
            GenericParser.character("@") *> GenericParser(result: "\0") <|>
            GenericParser.character("[") *>
            GenericParser(result: "\u{001B}") <|>
            GenericParser.character("]") *>
            GenericParser(result: "\u{001C}") <|>
            GenericParser.character("\\") *>
            GenericParser(result: "\u{001D}") <|>
            GenericParser.character("^") *>
            GenericParser(result: "\u{001E}") <|>
            GenericParser.character("_") *> GenericParser(result: "\u{001F}"))
    }

    static func characterFromInt(_ value: Int) -> CharacterParser {
        guard let scalar = UnicodeScalar.fromInt(value) else {
            let outsideMsg = LocalizedString(
                "value outside of Unicode codespace"
            )
            return GenericParser.fail(outsideMsg)
        }

        return GenericParser(result: Character(scalar))
    }

    private static func numberWithBase(
        _ base: Int,
        parser: CharacterParser
    ) -> IntParser {
        return parser.many1 >>- { digits in
            return integerWithDigits(String(digits), base: base)
        }
    }

    static func integerWithDigits(_ digits: String, base: Int) -> IntParser {
        guard let integer = Int(digits, radix: base) else {
            let overflowMsg = LocalizedString("Int overflow")
            return GenericParser.fail(overflowMsg)
        }

        return GenericParser(result: integer)
    }

    private static func doubleWithBase(
        _ base: Int,
        parser: CharacterParser
    ) -> DoubleParser {
        let baseDouble = Double(base)

        return parser.many1 >>- { digits in
            let double = digits.reduce(0.0) { acc, digit in
                baseDouble * acc + Double(Int(String(digit), radix: base)!)
            }

            return GenericParser(result: double)
        }
    }

    private static var doubleIntegerPart: DoubleParser {
        return GenericParser.decimalDigit.many1 >>- { digits in
            GenericParser(result: Double(String(digits))!)
        }
    }

    private static var naturalNumber: IntParser {
        let zeroNumber = GenericParser.character("0") *>
            (hexadecimal <|> octal <|> decimal <|> GenericParser(result: 0))
            <?> ""

        return zeroNumber <|> decimal
    }

    private static func sign<Number: SignedNumeric>()
        -> GenericParser<String, UserState, (Number) -> Number> {
        return GenericParser.character("-") *> GenericParser(result: -) <|>
            GenericParser.character("+") *> GenericParser(result: { $0 }) <|>
            GenericParser(result: { $0 })
    }

    private static func fractionalExponent(_ number: Double) -> DoubleParser {
        let fractionMsg = LocalizedString("fraction")

        let fract = CharacterParser.character(".") *>
            (GenericParser.decimalDigit.many1 <?> fractionMsg).map { digits in
                digits.reduceRight(0) { frac, digit in
                    (frac + Double(String(digit))!) / 10
                }
            }

        let exponentMsg = LocalizedString("exponent")

        let expo = GenericParser.oneOf("eE") *> sign() >>- { sign in
            (self.decimal <?> exponentMsg) >>- { exp in
                GenericParser(result: power(sign(exp)))
            }
        }

        let fraction = (fract <?> fractionMsg) >>- { frac in
            (expo <?> exponentMsg).otherwise(1) >>- { exp in
                return GenericParser(result: (number + frac) * exp)
            }
        }

        let exponent = expo >>- { exp in
            GenericParser(result: number * exp)
        }

        return fraction <|> exponent
    }

    private func caseString(_ name: String) -> StrParser {
        if languageDefinition.isCaseSensitive {
            return StrParser.string(name)
        }

        func walk(_ string: String) -> VoidParser {
            let unit = VoidParser(result: ())

            guard !string.isEmpty else { return unit }

            var str = string
            let char = str.remove(at: str.startIndex)

            let charParser: VoidParser
            if char.isAlpha {
                charParser = (GenericParser.character(char.lowercase) <|>
                    GenericParser.character(char.uppercase)) *> unit
            } else {
                charParser = GenericParser.character(char) *> unit
            }

            return (charParser <?> name) >>- { _ in walk(str) }
        }

        return walk(name) *> GenericParser(result: name)
    }
}

private let hexadecimalPrefixes = "xX"
private let octalPrefixes = "oO"

private let substituteCharacter: Character = "\u{001A}"

private let escapeMap: [(esc: Character, code: Character)] = [
    ("a", "\u{0007}"), ("b", "\u{0008}"), ("f", "\u{000C}"), ("n", "\n"),
    ("r", "\r"), ("t", "\t"), ("v", "\u{000B}"), ("\\", "\\"), ("\"", "\""),
    ("'", "'")
]

private let asciiCodesMap: [(esc: String, code: Character)] = [
    ("NUL", "\u{0000}"), ("SOH", "\u{0001}"), ("STX", "\u{0002}"),
    ("ETX", "\u{0003}"), ("EOT", "\u{0004}"), ("ENQ", "\u{0005}"),
    ("ACK", "\u{0006}"), ("BEL", "\u{0007}"), ("BS", "\u{0008}"),
    ("HT", "\u{0009}"), ("LF", "\u{000A}"), ("VT", "\u{000B}"),
    ("FF", "\u{000C}"), ("CR", "\u{000D}"), ("SO", "\u{000E}"),
    ("SI", "\u{000F}"), ("DLE", "\u{0010}"), ("DC1", "\u{0011}"),
    ("DC2", "\u{0012}"), ("DC3", "\u{0013}"), ("DC4", "\u{0014}"),
    ("NAK", "\u{0015}"), ("SYN", "\u{0016}"), ("ETB", "\u{0017}"),
    ("CAN", "\u{0018}"), ("EM", "\u{0019}"), ("SUB", "\u{001A}"),
    ("ESC", "\u{001B}"), ("FS", "\u{001C}"), ("GS", "\u{001D}"),
    ("RS", "\u{001E}"), ("US", "\u{001F}"), ("SP", "\u{0020}"),
    ("DEL", "\u{007F}")
]

private func power(_ exp: Int) -> Double {
    if exp < 0 {
        return 1.0 / power(-exp)
    }

    return pow(10.0, Double(exp))
}
