//
//  Position.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-09-04.
//  Copyright © 2015 David Dufresne. All rights reserved.
//
// Textual source positions.
//

import Foundation

/// SourcePosition represents source positions. It contains the name of the source (i.e. file name), a line number and a column number. The upper left is 1, 1. It implements the `Comparable` and `CustomStringConvertible` protocols. The comparison is made using line and column number.
public struct SourcePosition: Comparable, CustomStringConvertible {
    
    /// The name of the source (i.e. file name)
    public var name: String
    
    /// The line number in the source.
    public var line: Int
    
    /// The column number in the source.
    public var column: Int
    
    /// A textual representation of `self`.
    public var description: String {
        
        let lineMsg = NSLocalizedString("line", comment: "Error messages.")
        let columnMsg = NSLocalizedString("column", comment: "Error messages.")
        
        var desc = "(" + lineMsg + " \(line), " + columnMsg + " \(column))"
        
        if !name.isEmpty {
            
            desc = "\"\(name)\" " + desc
            
        }
        
        return desc
        
    }
    
    /// Update a source position given a character. If the character is a newline ("\n") or carriage return ("\r") the line number is incremented by 1. If the character is a tab ("\t") the column number is incremented to the nearest 8'th column, ie. `column + 8 - ((column - 1) % 8)`. In all other cases, the column is incremented by 1.
    ///
    /// - parameter char: The tested character indicating how to update the position.
    mutating func updatePosition(char: Character) {
        
        switch char {
            
        case "\n":
            
            line += 1
            column = 1
            
        case "\t":
            
            column = column + 8 - ((column - 1) % 8)
            
        default: column += 1
            
        }
        
    }
    
}

/// Equality based on the line and column number.
public func ==(leftPos: SourcePosition, rightPos: SourcePosition) -> Bool {
    
    return leftPos.line == rightPos.line && leftPos.column == rightPos.column
    
}

/// Comparison based on the line and column number.
public func <(leftPos: SourcePosition, rightPos: SourcePosition) -> Bool {
    
    if leftPos.line < rightPos.line {
        
        return true
        
    } else if leftPos.line == rightPos.line {
        
        if leftPos.column < rightPos.column { return true }
        
    }
    
    return false
    
}
