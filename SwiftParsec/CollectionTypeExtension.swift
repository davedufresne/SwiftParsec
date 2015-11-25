//
//  CollectionTypeExtension.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-10-09.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

extension CollectionType {
    
    /// Return the result of repeatedly calling `combine` with an accumulated value initialized to `initial` and each element of `self`, in turn from the right, i.e. return combine(combine(...combine(combine(initial, self[count-1]), self[count-2]), self[count-3]), ... self[0]).
    ///
    /// - parameters:
    ///   - initial: The initial value.
    ///   - combine: The combining function.
    /// - returns: The combined result of each element of `self`.
    func reduceRight<T>(initial: T, @noescape combine: (T, Self.Generator.Element) throws -> T) rethrows -> T {
        
        var acc = initial
        
        for elem in reverse() {
            
            acc = try combine(acc, elem)
            
        }
        
        return acc
        
    }
    
}
