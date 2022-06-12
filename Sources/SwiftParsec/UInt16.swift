// ==============================================================================
// UInt16.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-11-22.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// UInt16 extension
// ==============================================================================

// ==============================================================================
// Extension containing various utility methods related to characters.
extension UInt16 {
    /// `true` if `self` is a single code unit.
    var isSingleCodeUnit: Bool {
        return self >= 0x0000 && self <= 0xD7FF ||
            self >= 0xE000 && self <= 0xFFFF
    }
}
