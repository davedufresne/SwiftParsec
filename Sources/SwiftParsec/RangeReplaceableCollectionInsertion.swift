// ==============================================================================
// RangeReplaceableCollectionInsertion.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-09-11.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// RangeReplaceableCollection extension
// ==============================================================================

// ==============================================================================
// Extension containing insertion methods.
public extension RangeReplaceableCollection {
    /// Prepend `newElement` to the collection.
    ///
    /// - parameter newElement: New element to prepend to the collection.
    mutating func prepend(_ newElement: Iterator.Element) {
        insert(newElement, at: startIndex)
    }

    /// Returns a new collection containing the elements of `self` with
    /// `newElement` prepended at the beginning.
    ///
    /// - parameter newElement: New element to prepend.
    /// - returns: A copy of `self` plus `newElement` prepended.
    func prepending(_ newElement: Iterator.Element) -> Self {
        var mutableSelf = self
        mutableSelf.prepend(newElement)

        return mutableSelf
    }

    /// Returns a new collection containing the elements of `self` with
    /// `newElement` appended to the end.
    ///
    /// - parameter newElement: New element to append.
    /// - returns: A copy of `self` plus `newElement` appended.
    func appending(_ newElement: Iterator.Element) -> Self {
        var mutableSelf = self
        mutableSelf.append(newElement)

        return mutableSelf
    }
}
