# Release 3.0.0

Migrated source code to Swift 4.0

# Release 2.1

Added support for linux.

# Release 2.0.1

Moved operators implementation in `Parsec` extension

# Release 2.0

## General

- Migrated source code to Swift 3.0
- Now Support Swift Package Manager
- Improved files and source code layout
- More documentation

## Performance

A benchmark was added to test the performance of the library.

An internal design modification greatly improved the parsing speed and memory
usage. Before the modification the benchmark measured 648.32s (≈10.8m) to
execute the parsing of a huge JSON file. Now it only takes 6.7s, a bit more than
96 times faster!

## API

- Added the `userState: GenericParser<StreamType, UserState, UserState>`
parser.
- Now the `run(userState: UserState, sourceName: String, input: StreamType)
throws -> Result` only returns the result of the parsing. As an example, if one
wants to get the user state and the result at the same time:
```
let countLine = GenericParser<String, Int, Character>.endOfLine >>- { newLine in

    GenericParser<String, Int, Int>.userState >>- { userState in

        GenericParser(result: (newLine, userState + 1))

    }

}

```
- Added the `Parsec.runSafe(userState: UserState, sourceName: String,
input: StreamType) -> Either<ParseError, Result>` method. This new method does
not throw exceptions but returns the result wrap in an `Either` type.
- Added a parser returning the current source position:
`GenericParser.sourcePosition: GenericParser<StreamType, UserState, SourcePosition>`
- Various minor changes to conform to the Swift API design guide lines

# Release 1.1

- Fixed wrong parse error type returned by `GenericParser.unexpected()`
- Added missing guard statement to prevent crash in `UnicodeScalar.fromUInt32()`
- Added `ClosedInterval` variant of `ParsecType.oneOf()`
- Migration to Swift 2.2
- Internal code improvement
- Increased tests coverage
- Documentation improvement
