//
//  Language.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-10-14.
//  Copyright © 2015 David Dufresne. All rights reserved.
//
//  A helper module that defines some language definitions that can be used to instantiate a token parser (see "Token").

import Foundation

/// The `LanguageDefinition` structure contains all parameterizable features of the token parser. There is some default definitions provided by SwiftParsec.
public struct LanguageDefinition<UserState> {
    
    /// Describe the start of a block comment. Use the empty string if the language doesn't support block comments. For example "/*".
    public var commentStart: String
    
    /// Describe the end of a block comment. Use the empty string if the language doesn't support block comments. For example "*/".
    public var commentEnd: String
    
    /// Describe the start of a line comment. Use the empty string if the language doesn't support line comments. For example "//".
    public var commentLine: String
    
    /// Set to `true` if the language supports nested block comments.
    public var allowNestedComments: Bool
    
    /// This parser should accept any start characters of identifiers. For example `letter <|> character("_")`.
    public var identifierStart: GenericParser<String, UserState, Character>
    
    /// This parser should accept any legal tail characters of identifiers. For example `alphaNum <|> character("_")`. The function receives the character parsed by `identifierStart` as parameter, allowing to handle special cases (i.e. implicit parameters in swift start with a '$' that must be followed by decimal digits only).
    public var identifierLetter: Character -> GenericParser<String, UserState, Character>
    
    /// This parser should accept any start characters of operators. For example `oneOf(":!#$%&*+./<=>?@\\^|-~")`
    public var operatorStart: GenericParser<String, UserState, Character>
    
    /// This parser should accept any legal tail characters of operators. Note that this parser should even be defined if the language doesn't support user-defined operators, or otherwise the `reservedOperators` parser won't work correctly.
    public var operatorLetter: GenericParser<String, UserState, Character>
    
    /// The set of reserved identifiers.
    public var reservedNames: Set<String>
    
    /// The set of reserved operators.
    public var reservedOperators: Set<String>
    
    /// This optional parser should accept escaped characters. This parser will also replace the string gap and zero-width escape sequence parsers. The default escape sequences have the following form: '\97' '\x61', '\o141', '\^@', '\n', \NUL.
    public var characterEscape: GenericParser<String, UserState, Character>?
    
    /// Set to `true` if the language is case sensitive.
    public var isCaseSensitive: Bool
    
}

public extension LanguageDefinition {
    
    /// This is the most minimal token definition. It is recommended to use this definition as the basis for other definitions. `empty` has no reserved names or operators, is case sensitive and doesn't accept comments, identifiers or operators.
    public static var empty: LanguageDefinition {
        
        return LanguageDefinition(
            commentStart:        "",
            commentEnd:          "",
            commentLine:         "",
            allowNestedComments: true,
            identifierStart:     GenericParser.letter <|> GenericParser.character("_"),
            identifierLetter:    { _ in GenericParser.alphaNumeric <|> GenericParser.character("_") },
            operatorStart:       GenericParser.oneOf(emptyOperatorLetterCharacters),
            operatorLetter:      GenericParser.oneOf(emptyOperatorLetterCharacters),
            reservedNames:       [],
            reservedOperators:   [],
            characterEscape:     nil,
            isCaseSensitive:     true
        )
        
    }
    
    /// This is a minimal token definition for Java style languages. It defines the style of comments, valid identifiers and case sensitivity. It does not define any reserved words or operators.
    public static var javaStyle: LanguageDefinition {
        
        var javaDef = empty
        
        javaDef.commentStart = "/*"
        javaDef.commentEnd   = "*/"
        javaDef.commentLine  = "//"
        
        return javaDef
        
    }
    
    // This is a definition for the JSON language-independent data interchange format.
    public static var json: LanguageDefinition {
        
        var jsonDef = empty
        
        let charEscParsers: [GenericParser<String, UserState, Character>] =
        jsonEscapeMap.map { escCode in
            
            GenericParser.character(escCode.esc) *> GenericParser(result: escCode.code)
            
        }
        
        let charEscape = GenericParser.choice(charEscParsers)
        
        let hexaNum: GenericParser<String, UserState, UInt16> =
        GenericParser.hexadecimalDigit.count(jsonMaxEscapeDigit) >>- { digits in
            
            // The max possible value of `digits` is 0xFFFF, so no possible overflow.
            let integer = UInt16(String(digits), radix: 16)!
            return GenericParser(result: integer)
            
        }
        
        let backslash = GenericParser<String, UserState, Character>.character("\\")
        
        let codePoint = GenericParser.character("u") *> hexaNum
        let encodedChar: GenericParser<String, UserState, Character> =
        codePoint >>- { cp1 in
            
            if cp1.isSingleCodeUnit {
                
                return GenericParser(result: Character(UnicodeScalar(cp1)))
                
            }
            
            return backslash *> codePoint >>- { cp2 in
                
                let cps = [cp1, cp2]
                guard let str = String(codeUnits: cps, codec: UTF16()) else {
                    
                    let decodingErrorMsg = NSLocalizedString("decoding error", comment: "JSON language definition.")
                    return GenericParser.fail(decodingErrorMsg)
                    
                }
                
                return GenericParser(result: str[str.startIndex])
                
            } <?> NSLocalizedString("surrogate pair", comment: "JSON language definition.")
            
        }
        
        let escapeCodeMsg = NSLocalizedString("escape code", comment: "JSON language definition.")
        let characterEscape = backslash *>
            (charEscape <|> encodedChar <?> escapeCodeMsg)
        jsonDef.characterEscape = characterEscape
        
        return jsonDef
        
    }
    
    /// This is a minimal token definition for the swift 2.1 language. It defines the style of comments, valid identifiers and operators, reserved names and operators, character escaping, and case sensitivity.
    public static var swift: LanguageDefinition {
        
        var swiftDef = empty
        
        swiftDef.commentStart      = "/*"
        swiftDef.commentEnd        = "*/"
        swiftDef.commentLine       = "//"
        
        swiftDef.identifierStart   = GenericParser.memberOf(swiftIdentifierStartSet) <|>
            GenericParser.character(swiftImplicitParameterStart)
        
        swiftDef.identifierLetter  = { char in
            
            if char == swiftImplicitParameterStart {
                
                return GenericParser.decimalDigit
                
            }
            
            return GenericParser.memberOf(swiftIdentifierLetterSet)
            
        }
        
        swiftDef.operatorStart     = GenericParser.memberOf(swiftOperatorStartSet)
        swiftDef.operatorLetter    = GenericParser.memberOf(swiftOperatorLetterSet)
        
        swiftDef.reservedNames     = ["Self", "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__", "as", "break", "case", "catch", "class", "continue", "default", "defer", "deinit", "do", "dynamicType", "else", "enum", "extension", "fallthrough", "false", "for", "func", "guard", "if", "import", "in", "init", "inout", "internal", "is", "let", "nil", "operator", "private", "protocol", "public", "repeat", "rethrows", "return", "self", "static­", "struct", "subscript", "super", "switch", "throw", "throws", "true", "try", "typealias", "var", "where", "while"]
        swiftDef.reservedOperators = ["=", "->", ".", ",", ":", "@", "#", "<", "&", "`", "?", ">", "!"]
        
        let charEscParsers: [GenericParser<String, UserState, Character>] =
        swiftEscapeMap.map { escCode in
            
            GenericParser.character(escCode.esc) *> GenericParser(result: escCode.code)
            
        }
        
        let charEscape = GenericParser.choice(charEscParsers)
        
        let hexaChar: GenericParser<String, UserState, Character> =
        (GenericParser.hexadecimalDigit <?> "").many1 >>- { digits in
            
            let num = String(digits)
            return GenericTokenParser.integerWithDigits(num, base: 16) >>- { intVal in
                
                GenericTokenParser.characterFromInt(intVal)
                
            } <?> NSLocalizedString("escape sequence", comment: "Swift language definition.")
            
        } <?> NSLocalizedString("hexadecimal digit(s)", comment: "Swift language definition.")
        
        let charNumber = GenericParser<String, UserState, Character>.string("u{") *>
            hexaChar <* GenericParser.character("}")
        
        let escapeCodeMsg = NSLocalizedString("escape code", comment: "Swift language definition.")
        let characterEscape = GenericParser.character("\\") *>
            (charEscape <|> charNumber <?> escapeCodeMsg)
        swiftDef.characterEscape = characterEscape
        
        return swiftDef
        
    }
    
}

//
// Empty definition
//
private let emptyOperatorLetterCharacters = ":!$%&*+./<=>?\\^|-~"

//
// JSON definition
//
private let jsonEscapeMap: [(esc: Character, code: Character)] = [("\"", "\""), ("\\", "\\"), ("/", "/"), ("b", "\u{0008}"), ("f", "\u{000C}"), ("n", "\n"), ("r", "\r"), ("t", "\t")]

private let jsonMaxEscapeDigit = 4

//
// Swift definition
//
private let swiftImplicitParameterStart: Character = "$"

private let swiftIdentifierStartCharacters =
    swiftIdentifierStartCharacters1 +
    swiftIdentifierStartCharacters2 +
    swiftIdentifierStartCharacters3 +
    swiftIdentifierStartCharacters4

// Split declaration of swiftIdentifierStartCharacter because "Expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions" error.
private let swiftIdentifierStartCharacters1 =
    (0x0041...0x005A).stringValue + // 'A' to 'Z'
    (0x0061...0x007A).stringValue + // 'a' to 'z'
    "_" +
    "\u{00A8}\u{00AA}\u{00AD}\u{00AF}" +
    (0x00B2...0x00B5).stringValue +
    (0x00B7...0x00BA).stringValue +
    (0x00BC...0x00BE).stringValue +
    (0x00C0...0x00D6).stringValue +
    (0x00D8...0x00F6).stringValue +
    (0x00F8...0x00FF).stringValue +
    (0x0100...0x02FF).stringValue +
    (0x0370...0x167F).stringValue +
    (0x1681...0x180D).stringValue +
    (0x180F...0x1DBF).stringValue +
    (0x1E00...0x1FFF).stringValue

private let swiftIdentifierStartCharacters2 =
    (0x200B...0x200D).stringValue +
    (0x202A...0x202E).stringValue +
    (0x203F...0x2040).stringValue +
    "\u{2054}" +
    (0x2060...0x206F).stringValue +
    (0x2070...0x20CF).stringValue +
    (0x2100...0x218F).stringValue +
    (0x2460...0x24FF).stringValue +
    (0x2776...0x2793).stringValue +
    (0x2C00...0x2DFF).stringValue +
    (0x2E80...0x2FFF).stringValue

private let swiftIdentifierStartCharacters3 =
    (0x3004...0x3007).stringValue +
    (0x3021...0x302F).stringValue +
    (0x3031...0x303F).stringValue +
    (0x3040...0xD7FF).stringValue +
    (0xF900...0xFD3D).stringValue +
    (0xFD40...0xFDCF).stringValue +
    (0xFDF0...0xFE1F).stringValue +
    (0xFE30...0xFE44).stringValue +
    (0xFE47...0xFFFD).stringValue

private let swiftIdentifierStartCharacters4 =
    (0x10000...0x1FFFD).stringValue +
    (0x20000...0x2FFFD).stringValue +
    (0x30000...0x3FFFD).stringValue +
    (0x40000...0x4FFFD).stringValue +
    (0x50000...0x5FFFD).stringValue +
    (0x60000...0x6FFFD).stringValue +
    (0x70000...0x7FFFD).stringValue +
    (0x80000...0x8FFFD).stringValue +
    (0x90000...0x9FFFD).stringValue +
    (0xA0000...0xAFFFD).stringValue +
    (0xB0000...0xBFFFD).stringValue +
    (0xC0000...0xCFFFD).stringValue +
    (0xD0000...0xDFFFD).stringValue +
    (0xE0000...0xEFFFD).stringValue

private let swiftIdentifierStartSet = NSCharacterSet(charactersInString: swiftIdentifierStartCharacters)

private let swiftIdentifierLetterCharacters =
    swiftIdentifierStartCharacters +
    "0123456789" +
    (0x0300...0x036F).stringValue +
    (0x1DC0...0x1DFF).stringValue +
    (0x20D0...0x20FF).stringValue +
    (0xFE20...0xFE2F).stringValue

private let swiftIdentifierLetterSet = NSCharacterSet(charactersInString: swiftIdentifierLetterCharacters)

private let swiftOperatorStartCharacters =
    "/=-+!*%<>&|^?~" +
    (0x00A1...0x00A7).stringValue +
    "\u{00A9}\u{00AB}" +
    "\u{00AC}\u{00AE}" +
    "\u{00B0}\u{00B1}\u{00B6}\u{00BB}\u{00BF}\u{00D7}\u{00F7}" +
    (0x2016...0x2017).stringValue +
    (0x2020...0x2027).stringValue +
    (0x2030...0x203E).stringValue +
    (0x2041...0x2053).stringValue +
    (0x2055...0x205E).stringValue +
    (0x2190...0x23FF).stringValue +
    (0x2500...0x2775).stringValue +
    (0x2794...0x2BFF).stringValue +
    (0x2E00...0x2E7F).stringValue +
    (0x3001...0x3003).stringValue +
    (0x3008...0x3030).stringValue

private let swiftOperatorStartSet = NSCharacterSet(charactersInString: swiftOperatorStartCharacters)

private let swiftOperatorLetterCharacters =
    swiftOperatorStartCharacters +
    (0x0300...0x036F).stringValue +
    (0x1DC0...0x1DFF).stringValue +
    (0x20D0...0x20FF).stringValue +
    (0xFE00...0xFE0F).stringValue +
    (0xFE20...0xFE2F).stringValue +
    (0xE0100...0xE01EF).stringValue

private let swiftOperatorLetterSet = NSCharacterSet(charactersInString: swiftOperatorLetterCharacters)

private let swiftEscapeMap: [(esc: Character, code: Character)] = [("n", "\n"), ("r", "\r"), ("t", "\t"), ("\\", "\\"), ("\"", "\""), ("'", "'"), ("0", "\0")]
