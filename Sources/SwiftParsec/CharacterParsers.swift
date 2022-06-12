// ==============================================================================
// CharacterParsers.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-09-16.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// Commonly used character parsers.
// ==============================================================================

/// String parser with an empty `UserState`.
public typealias StringParser = GenericParser<String, (), Character>

// ==============================================================================
// Extension containing methods related to character parsing.
public extension Parsec
where StreamType.Iterator.Element == Character, Result == Character {
    /// Return a parser that succeeds for any character for which the supplied
    /// function `predicate` returns `true`. The parser returns the character
    /// that is actually parsed.
    ///
    /// - parameter predicate: The predicate to apply on the `Character`.
    /// - returns: A parser that succeeds for any character for which the
    ///   supplied function `predicate` returns `true`.
    static func satisfy(
        _ predicate: @escaping (Character) -> Bool
    ) -> GenericParser<StreamType, UserState, Result> {
        return tokenPrimitive(
            tokenDescription: { String(reflecting: $0) },
            nextPosition: { position, elem in
                var pos = position
                pos.updatePosition(elem)

                return pos
            },
            match: { elem in
                predicate(elem) ? elem : nil
            })
    }

    /// Return a parser that succeeds if the current character is in the
    /// supplied list of characters. It returns the parsed character.
    ///
    ///     let vowel = StringParser.oneOf("aeiou")
    ///
    /// - parameter list: A `String` of possible characters to match.
    /// - returns: A parser that succeeds if the current character is in the
    ///   supplied list of characters.
    /// - SeeAlso:
    ///   `GenericParser.satisfy(
    ///       predicate: Character -> Bool
    ///   ) -> GenericParser`
    static func oneOf(
        _ list: String
    ) -> GenericParser<StreamType, UserState, Result> {
        return satisfy(list.contains)
    }

    /// Return a parser that succeeds if the current character is in the
    /// supplied interval of characters. It returns the parsed character.
    ///
    ///     let digit = StringParser.oneOf("0"..."9")
    ///
    /// - parameter interval: A `ClosedInterval` of possible characters to
    ///   match.
    /// - returns: A parser that succeeds if the current character is in the
    ///   supplied interval of characters.
    /// - SeeAlso:
    ///   `GenericParser.satisfy(
    ///       predicate: Character -> Bool
    ///   ) -> GenericParser`
    static func oneOf(
        _ interval: ClosedRange<Character>
    ) -> GenericParser<StreamType, UserState, Result> {
        return satisfy(interval.contains)
    }

    /// Return a parser that succeeds if the current character is _not_ in the
    /// supplied list of characters. It returns the parsed character.
    ///
    ///     let consonant = StringParser.noneOf("aeiou")
    ///
    /// - parameter list: A `String` of possible _not_ to match.
    /// - returns: A parser that succeeds if the current character is _not_ in
    ///   the supplied list of characters.
    static func noneOf(
        _ list: String
    ) -> GenericParser<StreamType, UserState, Result> {
        return satisfy { !list.contains($0) }
    }

    /// A Parser that skips _zero_ or more unicode white space characters.
    ///
    /// - SeeAlso: `GenericParser.skipMany`.
    static var spaces: GenericParser<StreamType, UserState, ()> {
        return space.skipMany <?> LocalizedString("white space")
    }

    /// A Parser that parses a white space character (any Unicode space
    /// character, and the control characters \t, \n, \r, \f, \v). It returns
    /// the parsed character.
    static var unicodeSpace: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isUnicodeSpace } <?> LocalizedString("unicode space")
    }

    /// A Parser that parses any space character, and the control characters \t,
    /// \n, \r, \f, \v. It returns the parsed character.
    static var space: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isSpace } <?> LocalizedString("space")
    }

    /// A Parser that parses a newline character ("\n"). It returns a newline
    /// character.
    static var newLine: GenericParser<StreamType, UserState, Result> {
        return character("\n") <?> LocalizedString("lf new-line")
    }

    /// A Parser that parses a carriage return character ("\r") followed by a
    /// newline character ("\n"). It returns a newline character.
    static var crlf: GenericParser<StreamType, UserState, Result> {
        // "\r\n" is combined in one Unicode Scalar.
        return character("\r\n") *> GenericParser(result: "\n") <|>
            character("\r") *> character("\n") <?>
            LocalizedString("crlf new-line")
    }

    /// A Parser that parses a CRLF (see `crlf`) or LF (see `newLine`)
    /// end-of-line. It returns a newline character ("\n").
    ///
    ///     let endOfLine = StringParser.newline <|> StringParser.crlf
    static var endOfLine: GenericParser<StreamType, UserState, Result> {
        return newLine <|> crlf <?> LocalizedString("new-line")
    }

    /// A Parser that parses a tab character ("\t"). It returns a tab character.
    static var tab: GenericParser<StreamType, UserState, Result> {
        return character("\t") <?> LocalizedString("tab")
    }

    /// A Parser that parses a character in the category of Uppercase and
    /// Titlecase Letters. It returns the parsed character.
    static var uppercase: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isUppercase } <?> LocalizedString("uppercase letter")
    }

    /// A Parser that parses a character in the category of Lowercase Letters.
    /// It returns the parsed character.
    static var lowercase: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isLowercase } <?> LocalizedString("lowercase letter")
    }

    /// A Parser that parses a character in the categories of Letters, Marks,
    /// and Numbers. It returns the parsed character.
    static var alphaNumeric: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isAlphaNumeric } <?>
            LocalizedString("letter or digit")
    }

    /// A Parser that parses a character in the categories of Letters and Marks.
    /// It returns the parsed character.
    static var letter: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isAlpha } <?> LocalizedString("letter")
    }

    /// A Parser that parses a character in the categories of Symbols. It
    /// returns the parsed character.
    static var symbol: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isSymbol } <?> LocalizedString("symbol")
    }

    /// A Parser that parses a character in the category of Numbers. It returns
    /// the parsed character.
    static var digit: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isDigit } <?> LocalizedString("digit")
    }

    /// A Parser that parses an ASCII decimal digit, i.e. between "0" and "9".
    /// It returns the parsed character.
    static var decimalDigit: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isDecimalDigit } <?> LocalizedString("digit")
    }

    /// A Parser that parses an ASCII hexadecimal digit, i.e. "0"..."9",
    /// "a"..."f", "A"..."F". It returns the parsed character.
    static var hexadecimalDigit: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isHexadecimalDigit } <?>
            LocalizedString("hexadecimal digit")
    }

    /// A Parser that parses an octal digit (a character between "0" and "7").
    /// It returns the parsed character.
    static var octalDigit: GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isOctalDigit } <?>  LocalizedString("octal digit")
    }

    /// Return a parser that parses a single character `Character`. It returns
    /// the parsed character (i.e. `char`).
    ///
    ///     let semicolon  = StringParser.character(";")
    ///
    /// - parameter char: The character to parse.
    /// - returns: A parser that parses a single character `Character`.
    static func character(
        _ char: Character
    ) -> GenericParser<StreamType, UserState, Result> {
        return satisfy { $0 == char } <?> String(reflecting: char)
    }

    /// A Parser that succeeds for any character. It returns the parsed
    /// character.
    static var anyCharacter: GenericParser<StreamType, UserState, Result> {
        return satisfy { _ in true }
    }

    /// A Parser that maps a `Character` to a `String`.
    var stringValue: GenericParser<StreamType, UserState, String> {
        return map { String($0) }
    }

    /// Return a parser that succeeds for any character that are member of the
    /// supplied `CharacterSet`. It returns the parsed character.
    ///
    /// - parameter set: The `CharacterSet` used to test for membership.
    /// - returns: The parsed character.
    static func memberOf(
        _ set: CharacterSet
    ) -> GenericParser<StreamType, UserState, Result> {
        return satisfy { $0.isMember(of: set) }
    }
}

// ==============================================================================
// Extension containing methods related to result conversion.
public extension Parsec
where Result: Sequence, Result.Iterator.Element == Character {
    /// A Parser that maps an array of `Character` to a `String`.
    var stringValue: GenericParser<StreamType, UserState, String> {
        return map { String($0) }
    }
}

// ==============================================================================
// Extension containing methods related to string parsing.
public extension Parsec
where StreamType.Iterator.Element == Character {
    /// Return a parser that parses a `String`. It returns the parsed string
    /// (i.e. `str`).
    ///
    ///     let divOrMod = StringParser.string("div") <|>
    ///         StringParser.string("mod")
    ///
    /// - parameter str: The string to parse.
    /// - returns: A parser that parses a `String`.
    static func string(
        _ str: StreamType
    ) -> GenericParser<StreamType, UserState, StreamType> {
        return tokens(
            tokensDescription: { String(reflecting: $0) },
            nextPosition: { position, charStreamType in
                var pos = position
                for char in charStreamType {
                    pos.updatePosition(char)
                }

                return pos
            },
            tokens: str)
    }
}
