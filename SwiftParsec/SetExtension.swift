//
//  SetExtension.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-10-10.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

extension Set {
    
    /// Return a `Set` containing the results of mapping transform over `self`.
    ///
    /// - parameter transform: The transform function.
    /// - returns: A `Set` containing the results of mapping transform over `self`.
    func map<T>(@noescape transform: (Generator.Element) throws -> T) rethrows -> Set<T> {
        
        var mappedSet = Set<T>()
        
        for elem in self {
            
            mappedSet.insert(try transform(elem))
            
        }
        
        return mappedSet
        
    }
    
}
