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
    init?<C: UnicodeCodecType, S: SequenceType where S.Generator.Element == C.CodeUnit>(codeUnits: S, codec: C) {
        
        var unicodeCode = codec
        var str = ""
        
        var generator = codeUnits.generate()
        var done = false
        while !done {
            
            let result = unicodeCode.decode(&generator)
            switch result {
                
            case .EmptyInput: done = true
                
            case let .Result(val):
                
                str.append(Character(val))
                
            case .Error: return nil
                
            }
            
        }
        
        self = str
        
    }
    
    /// If `!self.isEmpty`, remove the first `Character` and return it, otherwise return nil.
    ///
    /// - returns: The first `Character` if `!self.isEmpty`.
    mutating public func popFirst() -> Character? {
        
        guard !isEmpty else { return nil }
        
        let first = self[startIndex]
        removeAtIndex(startIndex)
        
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
    func appending(c: Character) -> String {
        
        var mutableSelf = self
        mutableSelf.append(c)
        
        return mutableSelf
        
    }
    
}
