//
//  UnicodeScalarExtension.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-10-20.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

extension UnicodeScalar {
    
    /// The maximum value for a code point.
    static var max: Int { return 0x10FFFF }
    
    /// The minimum value for a code point.
    static var min: Int { return 0 }
    
    /// Return a `UnicodeScalar` with value `v` or nil if the value is outside of Unicode codespace or a surrogate pair code point.
    ///
    /// - parameter v: Unicode code point.
    /// - returns: A `UnicodeScalar` with value `v` or nil if the value is outside of Unicode codespace or a surrogate pair code point.
    static func fromInt(v: Int) -> UnicodeScalar? {
        
        guard v >= min && v <= max else { return nil }
        
        guard !isSurrogatePair(v) else { return nil }
        
        return UnicodeScalar(v)
        
    }
    
    /// Return a `UnicodeScalar` with value `v` or nil if the value is outside of Unicode codespace.
    ///
    /// - parameter v: Unicode code point.
    /// - returns: A `UnicodeScalar` with value `v` or nil if the value is outside of Unicode codespace.
    static func fromUInt32(v: UInt32) -> UnicodeScalar? {
        
        guard v >= UInt32(min) && v <= UInt32(max) else { return nil }
        
        guard !isSurrogatePair(v) else { return nil }
        
        return UnicodeScalar(v)
        
    }
    
    private static func isSurrogatePair<T: IntegerType>(v: T) -> Bool {
        
        return v >= 0xD800 && v <= 0xDFFF
        
    }
    
}
