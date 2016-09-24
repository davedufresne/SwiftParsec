//
//  SequenceConversion.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2016-09-24.
//  Copyright © 2016 David Dufresne. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == Int {
    
    /// Converts each `Int` in its `Character` equivalent and build a String
    /// with the result.
    var stringValue: String {
        
        let chars = map { Character(UnicodeScalar($0)!) }
        
        return String(chars)
        
    }
    
}
