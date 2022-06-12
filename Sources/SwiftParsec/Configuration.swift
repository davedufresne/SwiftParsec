// ==============================================================================
// Configuration.swift
// SwiftParsec
//
// Created by David Dufresne on 2016-05-27.
// Copyright © 2016 David Dufresne. All rights reserved.
//
// Configuration of the parsers framework
// ==============================================================================

// ==============================================================================
/// The `Configuration` type is used to customize the framework.
public struct Configuration {
    /// A hook to customize the localization of the strings contained in the
    /// framework. The default function simply returns the `key` passed as
    /// argument. A bundled application could use the sample
    /// _Localizable.strings_ file as a starting point for its own strings
    /// files and customize the framework this way:
    ///
    ///     Configuration.localizeString =
    ///         { NSLocalizedString($0, comment: "") }
    ///
    public static var localizeString: (_ key: String) -> String = { $0 }
}

// ==============================================================================
/// Function calling the string localization hook.
///
/// - parameters:
///   - key: The key for a string in the default table.
// swiftlint:disable:next identifier_name
func LocalizedString(_ key: String) -> String {
    return Configuration.localizeString(key)
}
