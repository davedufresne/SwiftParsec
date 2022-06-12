// ==============================================================================
// SequenceAggregation.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-09-14.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// Sequence extension
// ==============================================================================

// ==============================================================================
// Extension containing aggregation methods.
extension Sequence {
    /// Return a tuple containing the elements of `self`, in order, that satisfy
    /// the predicate `includeElement`. The second array of the tuple contains
    /// the remainder of the list.
    ///
    /// - parameter includeElement: The predicate function used to split the
    ///   sequence.
    /// - returns:
    ///   - included: The elements that satisfied the predicate.
    ///   - remainder: The remainder of `self`.
    func part(
        _ includeElement: (Self.Iterator.Element) throws -> Bool
    ) rethrows
    -> (included: [Self.Iterator.Element], remainder: [Self.Iterator.Element]) {
        var included: [Self.Iterator.Element] = []
        var remainder: [Self.Iterator.Element] = []

        for elem in self {
            if try includeElement(elem) {
                included.append(elem)
            } else {
                remainder.append(elem)
            }
        }

        return (included, remainder)
    }
}

// ==============================================================================
// Extension containing aggregation methods when the `Sequence` contains
// elements that are `Equatable`.
extension Sequence where Iterator.Element: Equatable {
    /// Return an array with the duplicate elements removed. In particular, it
    /// keeps only the first occurrence of each element.
    ///
    /// - returns: An array with the duplicate elements removed.
    func removingDuplicates() -> [Self.Iterator.Element] {
        return reduce([]) { (acc, elem) in
            guard !acc.contains(elem) else { return acc }

            return acc.appending(elem)
        }
    }
}
