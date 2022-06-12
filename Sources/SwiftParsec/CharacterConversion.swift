// ==============================================================================
// CharacterConversion.swift
// SwiftParsec
//
// Created by David Dufresne on 2016-09-24.
// Copyright © 2016 David Dufresne. All rights reserved.
//
// Character extension
// ==============================================================================

// ==============================================================================
// Extension containing methods related to the conversion of a character.
extension Character {
    /// The first `UnicodeScalar` of `self`.
    var unicodeScalar: UnicodeScalar {
        let unicodes = String(self).unicodeScalars
        return unicodes[unicodes.startIndex]
    }

    /// Lowercase `self`.
    var lowercase: Character {
        let str = String(self).lowercased()
        return str[str.startIndex]
    }

    /// Uppercase `self`.
    var uppercase: Character {
        let str = String(self).uppercased()
        return str[str.startIndex]
    }
}
