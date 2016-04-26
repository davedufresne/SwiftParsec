//
//  Permutation.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-11-01.
//  Copyright © 2015 David Dufresne. All rights reserved.
//
// This module implements permutation parsers.

/// The type `Permutation` denotes a permutation that can be converted to a `GenericParser` that returns an array of values of type `Result` on success. The values in the array have the same order as the parsers in the permutation. In the following exemple `parser` applies to any permutation of the characters 'a', 'b' and 'c' and always returns the string `"abc"` on success.
///
///     let permutation: Permutation = [
///
///         (StringParser.character("a"), nil),
///         (StringParser.character("b"), nil),
///         (StringParser.character("c"), nil)
///
///     ]
///
///     let parser = permutation.parser.stringValue
///
public struct Permutation<Stream: StreamType, UserState, Result>: RangeReplaceableCollectionType, ArrayLiteralConvertible {
    
    /// Represents a valid position in the permutation.
    public typealias Index = Int
    
    /// Permutation's generator.
    public typealias Generator = IndexingGenerator<Permutation>
    
    /// Element type of the permutation.
    public typealias Element = (parser: GenericParser<Stream, UserState, Result>, otherwise: Result?)
    
    /// The position of the first element.
    public let startIndex = 0
    
    /// The permutation's "past the end" position.
    public var endIndex: Int { return parsers.count }
    
    // Backing store.
    private var parsers: [Element]
    
    /// Create an instance initialized with elements.
    ///
    /// - parameter arrayLiteral: Arrays of tuple containing a parser and an optional default value.
    public init(arrayLiteral elements: Element...) {
        
        parsers = elements
        
    }
    
    /// Create an empty instance.
    public init() { parsers = [] }
    
    /// A parser applying to the permutation of all the parsers contained in `self`.
    public var parser: GenericParser<Stream, UserState, [Result]> {
        
        return parserWithSeparator(GenericParser(result: ()))
        
    }
    
    /// A parser applying to the permutation of all the parsers contained in `self` separated by `separator`.
    ///
    /// - parameter separator: A separator to apply between each element of the permutation.
    public func parserWithSeparator<Separator>(separator: GenericParser<Stream, UserState, Separator>) -> GenericParser<Stream, UserState, [Result]> {
        
        let ps = parsers.map { elem in
            
            (parser: elem.parser.map { [$0] }, otherwise: elem.otherwise)
            
        }
        
        return permute(ps, separator: separator)
        
    }
    
    private typealias PermParser = GenericParser<Stream, UserState, [Result]>
    
    private func permute<Separator>(elements: [(parser: PermParser, otherwise: Result?)], separator: GenericParser<Stream, UserState, Separator>) -> PermParser {
        
        var permutation = ContiguousArray<PermParser>()
        
        let elementsRange = elements.startIndex..<elements.endIndex
        for index in elementsRange {
            
            let element = elements[index]
            
            var parser = element.parser
            if index == elementsRange.last {
                
                parser = emptyParser(parser, otherwise: element.otherwise)
                
            }
            
            let perm: PermParser = parser >>- { result in
                
                var elems = elements
                elems.removeAtIndex(index)
                
                let p: PermParser
                if elems.count > 1  {
                    
                    p = separator *> self.permute(elems, separator: separator)
                    
                } else {
                    
                    let elem = elems[0]
                    p = self.emptyParser(separator *> elem.parser, otherwise: elem.otherwise)
                    
                }
                
                return p >>- { results in
                    
                    var rs = results
                    rs.insertContentsOf(result, at: index)
                    
                    return GenericParser(result: rs)
                    
                }
                
            }
            
            permutation.append(perm)
            
        }
        
        return GenericParser.choice(permutation)
        
    }
    
    private func emptyParser(parser: PermParser, otherwise: Result?) -> PermParser {
        
        guard let def = otherwise else { return parser }
        
        return parser.otherwise([def])
        
    }
    
    /// Append a parser to the permutation. The added parser is not allowed to accept empty input - use `appendOptionalParser` instead.
    ///
    /// - parameter parser: The parser to append to the permutation.
    public mutating func appendParser(parser: GenericParser<Stream, UserState, Result>) {
        
        parsers.append((parser, nil))
        
    }
    
    /// Append an optional parser to the permutation. The parser is optional - if it cannot be applied, the default value `otherwise` will be used instead.
    ///
    /// - parameters:
    ///   - parser: The optional parser to append to the permutation.
    ///   - otherwise: The default value to use if the parser cannot be applied.
    public mutating func appendOptionalParser(parser: GenericParser<Stream, UserState, Result>, otherwise: Result) {
        
        parsers.append((parser, otherwise))
        
    }
    
    /// Replace the given subRange of elements with newElements.
    ///
    /// - parameters:
    ///   - subRange: Range of elements to replace.
    ///   - newElements: New elements replacing the previous elements contained in `subRange`.
    public mutating func replaceRange<C: CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Index>, with newElements: C) {
        
        parsers.replaceRange(subRange, with: newElements)
        
    }
    
    public subscript(position: Index) -> Element { return parsers[position] }
    
}
