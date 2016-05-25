//
//  StringExtension.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-10-10.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

extension String {
    
    /// Initialize a `String` from a sequence of code units.
    ///
    /// - parameters:
    ///   - codeUnits: Sequence of code units.
    ///   - codec: A unicode encoding scheme.
    init?<C: UnicodeCodec, S: Sequence where S.Iterator.Element == C.CodeUnit>(codeUnits: S, codec: C) {
        
        var unicodeCode = codec
        var str = ""
        
        var iterator = codeUnits.makeIterator()
        var done = false
        while !done {
            
            let result = unicodeCode.decode(&iterator)
            switch result {
                
            case .emptyInput: done = true
                
            case let .scalarValue(val):
                
                str.append(Character(val))
                
            case .error: return nil
                
            }
            
        }
        
        self = str
        
    }
    
    /// The last character of the string.
    ///
    /// If the string is empty, the value of this property is `nil`.
    var last: Character? {
        
        guard !isEmpty else { return nil }
        
        return self[index(before: endIndex)]
        
    }
    
    /// If `!self.isEmpty`, remove the first `Character` and return it, otherwise return nil.
    ///
    /// - returns: The first `Character` if `!self.isEmpty`.
    mutating public func popFirst() -> Character? {
        
        guard !isEmpty else { return nil }
        
        let first = self[startIndex]
        remove(at: startIndex)
        
        return first
        
    }
    
    /// Return a `String` with the duplicate characters removed. In particular, it keeps only the first occurrence of each element.
    ///
    /// - returns: A `String` with the duplicate characters removed.
    func removingDuplicates() -> String {
        
        return String(characters.removingDuplicates())
        
    }
    
    /// Return a new `String` with `c` adjoined to the end.
    ///
    /// - parameter c: Character to append.
    func appending(_ c: Character) -> String {
        
        var mutableSelf = self
        mutableSelf.append(c)
        
        return mutableSelf
        
    }
    
}
