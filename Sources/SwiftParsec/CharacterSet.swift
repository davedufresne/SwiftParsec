// ==============================================================================
// CharacterSet.swift
// SwiftParsec
//
// CharacterSet compatibility wrapper
// ==============================================================================

import struct Foundation.CharacterSet

#if _runtime(_ObjC)

/// Ideally, we could use this for all platforms, but open-source
/// `Foundation.CharacterSet` will fail at large sizes
public typealias CharacterSet = Foundation.CharacterSet

#else

// ==============================================================================
/// The `CharacterSet` is a thin wrapper around `Foundation.CharacterSet`. It
/// helps us avoid bugs in open-source version.
public struct CharacterSet {
    /// Indicates whether the set contains the given unicode character.
    public let contains: (UnicodeScalar) -> Bool

    /// Convenience factory for `Foundation.CharacterSet#uppercaseLetters`
    public static var uppercaseLetters: CharacterSet {
        return CharacterSet(Foundation.CharacterSet.uppercaseLetters)
    }

    /// Convenience factory for `Foundation.CharacterSet#lowercaseLetters`
    public static var lowercaseLetters: CharacterSet {
        return CharacterSet(Foundation.CharacterSet.lowercaseLetters)
    }

    /// Convenience factory for `Foundation.CharacterSet#decimalDigits`
    public static var decimalDigits: CharacterSet {
        return CharacterSet(Foundation.CharacterSet.decimalDigits)
    }

    /// Convenience factory for `Foundation.CharacterSet#symbols`
    public static var symbols: CharacterSet {
        return CharacterSet(Foundation.CharacterSet.symbols)
    }

    /// Convenience factory for `Foundation.CharacterSet#letters`
    public static var letters: CharacterSet {
        return CharacterSet(Foundation.CharacterSet.letters)
    }

    /// Convenience factory for `Foundation.CharacterSet#alphanumerics`
    public static var alphanumerics: CharacterSet {
        return CharacterSet(Foundation.CharacterSet.alphanumerics)
    }

    /// Alternative to `Foundation.CharacterSet#init` that does not fail for
    /// large inputs. It is likely less performant.
    public init(charactersIn: String) {
        self.contains = Set(charactersIn.unicodeScalars).contains
    }

    /// Convert a `Foundation.CharacterSet` to a `SwiftParsec.CharacterSet`
    public init(_ foundationSet: Foundation.CharacterSet) {
        self.contains = foundationSet.contains
    }
}

#endif
