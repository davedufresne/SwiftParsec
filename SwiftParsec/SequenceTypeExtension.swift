//
//  SequenceTypeExtension.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-14.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

extension SequenceType {
    
    /// Return a tuple containing the elements of `self`, in order, that satisfy the predicate `includeElement`. The second array of the tuple contains the remainder of the list.
    ///
    /// - parameter includeElement: The predicate function used to split the sequence.
    /// - returns:
    ///   - included: The elements that satisfied the predicate.
    ///   - remainder: The remainder of `self`.
    func part(@noescape includeElement: (Self.Generator.Element) throws -> Bool) rethrows -> (included: [Self.Generator.Element], remainder: [Self.Generator.Element]) {
        
        var included: [Self.Generator.Element] = []
        var remainder: [Self.Generator.Element] = []
        
        for elem in self {
            
            if (try includeElement(elem)) {
                
                included.append(elem)
                
            } else {
                
                remainder.append(elem)
                
            }
            
        }
        
        return (included, remainder)
        
    }
    
}

extension SequenceType where Generator.Element: Equatable {
    
    /// Return an array with the duplicate elements removed. In particular, it keeps only the first occurrence of each element.
    ///
    /// - returns: An array with the duplicate elements removed.
    func removingDuplicates() -> [Self.Generator.Element] {
        
        return reduce([]) { (acc, elem) in
            
            guard !acc.contains(elem) else { return acc }
            
            return acc.appending(elem)
            
        }
        
    }
    
}

extension SequenceType where Generator.Element == Int {
    
    /// Converts each `Int` in its `Character` equivalent and build a String with the result.
    var stringValue: String {
        
        var chars = ContiguousArray<Character>()
        
        for elem in self {
            
            chars.append(Character(UnicodeScalar(elem)))
            
        }
        
        return String(chars)
        
    }
    
}
