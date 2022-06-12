// ==============================================================================
// Permutation.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-11-01.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// This module implements permutation parsers.
// ==============================================================================

// ==============================================================================
/// The type `Permutation` denotes a permutation that can be converted to a
/// `GenericParser` that returns an array of values of type `Result` on success.
/// The values in the array have the same order as the parsers in the
/// permutation. In the following exemple `parser` applies to any permutation of
/// the characters 'a', 'b' and 'c' and always returns the string `"abc"` on
/// success.
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
public struct Permutation<StreamType: Stream, UserState, Result>:
RangeReplaceableCollection, ExpressibleByArrayLiteral {
    /// Represents a valid position in the permutation.
    public typealias Index = Int

    /// Permutation's generator.
    public typealias Iterator = IndexingIterator<Permutation>

    /// Element type of the permutation.
    public typealias Element = (
        parser: GenericParser<StreamType, UserState, Result>,
        otherwise: Result?
    )

    /// The position of the first element.
    public let startIndex = 0

    /// The permutation's "past the end" position.
    public var endIndex: Int { return parsers.count }

    // Backing store.
    private var parsers: [Element]

    /// Create an instance initialized with elements.
    ///
    /// - parameter arrayLiteral: Arrays of tuple containing a parser and an
    ///   optional default value.
    public init(arrayLiteral elements: Element...) {
        parsers = elements
    }

    /// Create an empty instance.
    public init() { parsers = [] }

    /// Returns the position immediately after i.
    ///
    /// - SeeAlso: `IndexableBase` protocol.
    public func index(after index: Permutation.Index) -> Permutation.Index {
        return parsers.index(after: index)
    }

    /// A parser applying to the permutation of all the parsers contained in
    /// `self`.
    public func makeParser() -> GenericParser<StreamType, UserState, [Result]> {
        return makeParser(separator: GenericParser(result: ()))
    }

    /// A parser applying to the permutation of all the parsers contained in
    /// `self` separated by `separator`.
    ///
    /// - parameter separator: A separator to apply between each element of the
    ///   permutation.
    public func makeParser<Separator>(
        separator: GenericParser<StreamType, UserState, Separator>
    ) -> GenericParser<StreamType, UserState, [Result]> {
        let permutableParsers = parsers.map { elem in
            (parser: elem.parser.map { [$0] }, otherwise: elem.otherwise)
        }

        return permute(permutableParsers, separator: separator)
    }

    private typealias PermParser =
        GenericParser<StreamType, UserState, [Result]>

    private func permute<Separator>(
        _ elements: [(parser: PermParser, otherwise: Result?)],
        separator: GenericParser<StreamType, UserState, Separator>
    ) -> PermParser {
        var permutation = ContiguousArray<PermParser>()

        let elementsRange = elements.indices
        for index in elementsRange {
            let element = elements[index]

            var parser = element.parser
            if index == elementsRange.last {
                parser = emptyParser(parser, otherwise: element.otherwise)
            }

            let perm: PermParser = parser >>- { result in
                var elems = elements
                elems.remove(at: index)

                let permParser: PermParser
                if elems.count > 1 {
                    permParser = separator *> self.permute(elems, separator: separator)
                } else {
                    let elem = elems[0]
                    permParser = self.emptyParser(
                        separator *> elem.parser,
                        otherwise: elem.otherwise
                    )
                }

                return permParser >>- { results in
                    var allResults = results
                    allResults.insert(contentsOf: result, at: index)

                    return GenericParser(result: allResults)
                }
            }

            permutation.append(perm)
        }

        return GenericParser.choice(permutation)
    }

    private func emptyParser(
        _ parser: PermParser,
        otherwise: Result?
    ) -> PermParser {
        guard let def = otherwise else { return parser }

        return parser.otherwise([def])
    }

    /// Append a parser to the permutation. The added parser is not allowed to
    /// accept empty input - use `appendOptionalParser` instead.
    ///
    /// - parameter parser: The parser to append to the permutation.
    public mutating func appendParser(
        _ parser: GenericParser<StreamType, UserState, Result>
    ) {
        parsers.append((parser, nil))
    }

    /// Append an optional parser to the permutation. The parser is optional -
    /// if it cannot be applied, the default value `otherwise` will be used
    /// instead.
    ///
    /// - parameters:
    ///   - parser: The optional parser to append to the permutation.
    ///   - otherwise: The default value to use if the parser cannot be applied.
    public mutating func appendOptionalParser(
        _ parser: GenericParser<StreamType, UserState, Result>,
        otherwise: Result
    ) {
        parsers.append((parser, otherwise))
    }

    /// Replace the given subRange of elements with newElements.
    ///
    /// - parameters:
    ///   - subRange: Range of elements to replace.
    ///   - newElements: New elements replacing the previous elements contained
    ///     in `subRange`.
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Index>,
        with newElements: C
    ) where C.Iterator.Element == Iterator.Element {
        parsers.replaceSubrange(subrange, with: newElements)
    }

    public subscript(position: Index) -> Element { return parsers[position] }
}
