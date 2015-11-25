//
//  UInt16Extension.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-11-22.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

extension UInt16 {
    
    /// `true` if `self` is a single code unit.
    var isSingleCodeUnit: Bool {
        
        return self >= 0x0000 && self <= 0xD7FF || self >= 0xE000 && self <= 0xFFFF
        
    }
    
}
