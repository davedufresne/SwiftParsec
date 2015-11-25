//
//  ArrayExtension.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-11.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

extension RangeReplaceableCollectionType where Generator.Element: Equatable {
    
    /// Remove all elements equal to `newElement` and insert `newElement` at the beginning of the returned array.
    ///
    /// - parameter newElement: New element to insert at the beginning of the returned array.
    /// - returns: An array with all elements equal to `newElement` removed and `newElement` at its beginning.
    func replaceWith(newElement: Generator.Element) -> [Generator.Element] {
        
        var filtered = filter { $0 != newElement }
        filtered.insert(newElement, atIndex: 0)
        
        return filtered
        
    }
    
}

public extension RangeReplaceableCollectionType {
    
    /// If `!self.isEmpty`, remove the first element and return it, otherwise return `nil`.
    ///
    /// - returns: The fhe first element of `self` or `nil`.
    public mutating func popFirst() -> Generator.Element? {
        
        guard !isEmpty else { return nil }
        
        return removeFirst()
        
    }
    
    mutating func insert<C : CollectionType where C.Generator.Element == Generator.Element>(collection: C, atIndex index: Index) {
        
        replaceRange(index..<index, with: collection)
        
    }
    
}
