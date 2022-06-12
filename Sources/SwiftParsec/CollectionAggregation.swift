// ==============================================================================
// CollectionAggregation.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-10-09.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// Collection extension
// ==============================================================================

// ==============================================================================
// Extension containing aggregation methods.
extension Collection {
    /// Return the result of repeatedly calling `combine` with an accumulated
    /// value initialized to `initial` and each element of `self`, in turn from
    /// the right, i.e. return combine(combine(...combine(combine(initial,
    /// self[count-1]), self[count-2]), self[count-3]), ... self[0]).
    ///
    /// - parameters:
    ///   - initial: The initial value.
    ///   - combine: The combining function.
    /// - returns: The combined result of each element of `self`.
    func reduceRight<T>(
        _ initial: T,
        combine: (T, Self.Iterator.Element) throws -> T
    ) rethrows -> T {
        var acc = initial
        for elem in reversed() {
            acc = try combine(acc, elem)
        }

        return acc
    }
}
