//
//  Character.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-16.
//  Copyright © 2015 David Dufresne. All rights reserved.
//
// Commonly used character parsers.
//

import class Foundation.NSCharacterSet

/// String parser with an empty `UserState`.
public typealias StringParser = GenericParser<String, (), Character>

public extension Parsec where StreamType.Element == Character, Result == Character {
    
    /// Return a parser that succeeds for any character for which the supplied function `predicate` returns `true`. The parser returns the character that is actually parsed.
    ///
    /// - parameter predicate: The predicate to apply on the `Character`.
    /// - returns: A parser that succeeds for any character for which the supplied function `predicate` returns `true`.
    public static func satisfy(_ predicate: (Character) -> Bool) -> GenericParser<StreamType, UserState, Result> {
        
        return tokenPrimitive(
            tokenDescription: { String(reflecting: $0) },
            nextPosition: { position, elem, _ in
                
                var pos = position
                pos.updatePosition(elem)
                
                return pos
                
            },
            match: { elem in
                
                predicate(elem) ? elem : nil
                
            })
        
    }
    
    /// Return a parser that succeeds if the current character is in the supplied list of characters. It returns the parsed character.
    ///
    ///     let vowel = StringParser.oneOf("aeiou")
    ///
    /// - parameter list: A `String` of possible characters to match.
    /// - returns: A parser that succeeds if the current character is in the supplied list of characters.
    /// - SeeAlso: `GenericParser.satisfy(predicate: Character -> Bool) -> GenericParser`
    public static func oneOf(_ list: String) -> GenericParser<StreamType, UserState, Result> {
        
        return satisfy(list.characters.contains)
        
    }
    
    /// Return a parser that succeeds if the current character is in the supplied interval of characters. It returns the parsed character.
    ///
    ///     let digit = StringParser.oneOf("0"..."9")
    ///
    /// - parameter interval: A `ClosedInterval` of possible characters to match.
    /// - returns: A parser that succeeds if the current character is in the supplied interval of characters.
    /// - SeeAlso: `GenericParser.satisfy(predicate: Character -> Bool) -> GenericParser`
    public static func oneOf(_ interval: ClosedRange<Character>) -> GenericParser<StreamType, UserState, Result> {
        
        return satisfy(interval.contains)
        
    }
    
    /// Return a parser that succeeds if the current character is _not_ in the supplied list of characters. It returns the parsed character.
    ///
    ///     let consonant = StringParser.noneOf("aeiou")
    ///
    /// - parameter list: A `String` of possible _not_ to match.
    /// - returns: A parser that succeeds if the current character is _not_ in the supplied list of characters.
    public static func noneOf(_ list: String) -> GenericParser<StreamType, UserState, Result> {
        
        return satisfy { !list.characters.contains($0) }
        
    }
    
    /// A Parser that skips _zero_ or more unicode white space characters.
    ///
    /// - SeeAlso: `GenericParser.skipMany`.
    public static var spaces: GenericParser<StreamType, UserState, ()> {
        
        return space.skipMany <?> NSLocalizedString("white space", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a white space character (any Unicode space character, and the control characters \t, \n, \r, \f, \v). It returns the parsed character.
    public static var unicodeSpace: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isUnicodeSpace } <?> NSLocalizedString("unicode space", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses any space character, and the control characters \t, \n, \r, \f, \v. It returns the parsed character.
    public static var space: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isSpace } <?> NSLocalizedString("space", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a newline character ("\n"). It returns a newline character.
    public static var newLine: GenericParser<StreamType, UserState, Result> {
        
        return character("\n") <?> NSLocalizedString("lf new-line", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a carriage return character ("\r") followed by a newline character ("\n"). It returns a newline character.
    public static var crlf: GenericParser<StreamType, UserState, Result> {
        
        return character("\r\n") *> GenericParser(result: "\n") <|> // "\r\n" is combined in one Unicode Scalar.
            character("\r") *> character("\n") <?> NSLocalizedString("crlf new-line", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a CRLF (see `crlf`) or LF (see `newLine`) end-of-line. It returns a newline character ("\n").
    ///
    ///     let endOfLine = StringParser.newline <|> StringParser.crlf
    public static var endOfLine: GenericParser<StreamType, UserState, Result> {
        
        return newLine <|> crlf <?> NSLocalizedString("new-line", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a tab character ("\t"). It returns a tab character.
    public static var tab: GenericParser<StreamType, UserState, Result> {
        
        return character("\t") <?> NSLocalizedString("tab", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a character in the category of Uppercase and Titlecase Letters. It returns the parsed character.
    public static var uppercase: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isUppercase } <?> NSLocalizedString("uppercase letter", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a character in the category of Lowercase Letters. It returns the parsed character.
    public static var lowercase: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isLowercase } <?> NSLocalizedString("lowercase letter", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a character in the categories of Letters, Marks, and Numbers. It returns the parsed character.
    public static var alphaNumeric: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isAlphaNumeric } <?> NSLocalizedString("letter or digit", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a character in the categories of Letters and Marks. It returns the parsed character.
    public static var letter: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isAlpha } <?> NSLocalizedString("letter", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a character in the categories of Symbols. It returns the parsed character.
    public static var symbol: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isSymbol } <?> NSLocalizedString("symbol", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses a character in the category of Numbers. It returns the parsed character.
    public static var digit: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isDigit } <?> NSLocalizedString("digit", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses an ASCII decimal digit, i.e. between "0" and "9". It returns the parsed character.
    public static var decimalDigit: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isDecimalDigit } <?> NSLocalizedString("digit", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses an ASCII hexadecimal digit, i.e. "0"..."9", "a"..."f", "A"..."F". It returns the parsed character.
    public static var hexadecimalDigit: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isHexadecimalDigit } <?>  NSLocalizedString("hexadecimal digit", comment: "Character parsers.")
        
    }
    
    /// A Parser that parses an octal digit (a character between "0" and "7"). It returns the parsed character.
    public static var octalDigit: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isOctalDigit } <?>  NSLocalizedString("octal digit", comment: "Character parsers.")
        
    }
    
    /// Return a parser that parses a single character `Character`. It returns the parsed character (i.e. `char`).
    ///
    ///     let semicolon  = StringParser.character(";")
    ///
    /// - parameter char: The character to parse.
    /// - returns: A parser that parses a single character `Character`.
    public static func character(_ char: Character) -> GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0 == char } <?> String(reflecting: char)
        
    }
    
    /// A Parser that succeeds for any character. It returns the parsed character.
    public static var anyCharacter: GenericParser<StreamType, UserState, Result> {
        
        return satisfy { _ in true }
        
    }
    
    /// A Parser that maps a `Character` to a `String`.
    public var stringValue: GenericParser<StreamType, UserState, String> {
        
        return map { String($0) }
        
    }
    
    /// Return a parser that succeeds for any character that are member of the supplied `NSCharacterSet`. It returns the parsed character.
    ///
    /// - parameter set: The `NSCharacterSet` used to test for membership.
    /// - returns: The parsed character.
    static func memberOf(_ set: NSCharacterSet) -> GenericParser<StreamType, UserState, Result> {
        
        return satisfy { $0.isMember(of: set) }
        
    }
    
}

public extension Parsec where Result: Sequence, Result.Iterator.Element == Character {
    
    /// A Parser that maps an array of `Character` to a `String`.
    public var stringValue: GenericParser<StreamType, UserState, String> {
        
        return map { String($0) }
        
    }
    
}

public extension Parsec where StreamType.Element == Character {
    
    /// Return a parser that parses a `String`. It returns the parsed string (i.e. `str`).
    ///
    ///     let divOrMod = StringParser.string("div") <|>
    ///         StringParser.string("mod")
    ///
    /// - parameter str: The string to parse.
    /// - returns: A parser that parses a `String`.
    public static func string(_ str: StreamType) -> GenericParser<StreamType, UserState, StreamType> {
        
        return tokens(
            tokensDescription: { String(reflecting: $0) },
            nextPosition: { position, charStreamType in
                
                var pos = position
                var cs = charStreamType
                
                var char: Character? = cs.popFirst()
                while char != nil {
                    
                    pos.updatePosition(char!)
                    char = cs.popFirst()
                    
                }
                
                return pos
                
            },
            tokens: str)
        
    }
    
}
