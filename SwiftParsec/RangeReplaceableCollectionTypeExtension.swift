//
//  ArrayExtension.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-11.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

public extension RangeReplaceableCollectionType {
    
    /// If `!self.isEmpty`, remove the first element and return it, otherwise return `nil`.
    ///
    /// - returns: The fhe first element of `self` or `nil`.
    public mutating func popFirst() -> Generator.Element? {
        
        guard !isEmpty else { return nil }
        
        return removeFirst()
        
    }
    
    /// Prepend `newElement` to the collection.
    ///
    /// - parameter newElement: New element to prepend to the collection.
    mutating func prepend(newElement: Generator.Element) {
        
        insert(newElement, atIndex: startIndex)
        
    }
    
    /// Returns a new collection containing the elements of `self` with `newElement` prepended at the beginning.
    ///
    /// - parameter newElement: New element to prepend.
    /// - returns: A copy of `self` plus `newElement` prepended.
    func prepending(newElement: Generator.Element) -> Self {
        
        var mutableSelf = self
        mutableSelf.prepend(newElement)
        
        return mutableSelf
        
    }
    
    /// Returns a new collection containing the elements of `self` with `newElement` appended to the end.
    ///
    /// - parameter newElement: New element to append.
    /// - returns: A copy of `self` plus `newElement` appended.
    func appending(newElement: Generator.Element) -> Self {
        
        var mutableSelf = self
        mutableSelf.append(newElement)
        
        return mutableSelf
        
    }

}
