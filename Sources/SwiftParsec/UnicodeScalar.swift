// ==============================================================================
// UnicodeScalar.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-10-20.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// UnicodeScalar extension
// ==============================================================================

// ==============================================================================
// Extension containing various utility methods.
extension UnicodeScalar {
    /// The maximum value for a code point.
    static var max: Int { return 0x10FFFF }

    /// The minimum value for a code point.
    static var min: Int { return 0 }

    /// Return a `UnicodeScalar` with value `v` or nil if the value is outside
    /// of Unicode codespace or a surrogate pair code point.
    ///
    /// - parameter v: Unicode code point.
    /// - returns: A `UnicodeScalar` with value `v` or nil if the value is
    ///   outside of Unicode codespace or a surrogate pair code point.
    static func fromInt(_ value: Int) -> UnicodeScalar? {
        guard value >= min && value <= max else { return nil }

        guard !isSurrogatePair(value) else { return nil }

        return UnicodeScalar(value)
    }

    /// Return a `UnicodeScalar` with value `value` or nil if the value is outside
    /// of Unicode codespace.
    ///
    /// - parameter value: Unicode code point.
    /// - returns: A `UnicodeScalar` with value `value` or nil if the value is
    ///   outside of Unicode codespace.
    static func fromUInt32(_ value: UInt32) -> UnicodeScalar? {
        guard value >= UInt32(min) && value <= UInt32(max) else { return nil }

        guard !isSurrogatePair(value) else { return nil }

        return UnicodeScalar(value)
    }

    private static func isSurrogatePair<T: BinaryInteger>(_ value: T) -> Bool {
        return value >= 0xD800 && value <= 0xDFFF
    }
}
