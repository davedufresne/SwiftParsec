import XCTest
@testable import SwiftParsecTests

XCTMain([
    testCase([
        ("testOneOf", CharacterTests.testOneOf),
        ("testOneOfInterval", CharacterTests.testOneOfInterval),
        ("testNoneOf", CharacterTests.testNoneOf),
        ("testSpaces", CharacterTests.testSpaces),
        ("testUnicodeSpace", CharacterTests.testUnicodeSpace),
        ("testSpace", CharacterTests.testSpace),
        ("testNewLine", CharacterTests.testNewLine),
        ("testCrlf", CharacterTests.testCrlf),
        ("testEndOfLine", CharacterTests.testEndOfLine),
        ("testTab", CharacterTests.testTab),
        ("testUppercase", CharacterTests.testUppercase),
        ("testLowercase", CharacterTests.testLowercase),
        ("testAlphaNumeric", CharacterTests.testAlphaNumeric),
        ("testLetter", CharacterTests.testLetter),
        ("testSymbol", CharacterTests.testSymbol),
        ("testDigit", CharacterTests.testDigit),
        ("testDecimalDigit", CharacterTests.testDecimalDigit),
        ("testHexadecimalDigit", CharacterTests.testHexadecimalDigit),
        ("testOctalDigit", CharacterTests.testOctalDigit),
        ("testString", CharacterTests.testString)
    ]),
    testCase([
        ("testLarge", CharacterSetTests.testLarge)
    ]),
    testCase([
        ("testChoice", CombinatorTests.testChoice),
        ("testOtherwise", CombinatorTests.testOtherwise),
        ("testOptional", CombinatorTests.testOptional),
        ("testDiscard", CombinatorTests.testDiscard),
        ("testBetween", CombinatorTests.testBetween),
        ("testSkipMany1", CombinatorTests.testSkipMany1),
        ("testMany1", CombinatorTests.testMany1),
        ("testSeparatedBy", CombinatorTests.testSeparatedBy),
        ("testSeparatedBy1", CombinatorTests.testSeparatedBy1),
        ("testDividedBy", CombinatorTests.testDividedBy),
        ("testDividedBy1", CombinatorTests.testDividedBy1),
        ("testCount", CombinatorTests.testCount),
        ("testChainRight", CombinatorTests.testChainRight),
        ("testChainRight1", CombinatorTests.testChainRight1),
        ("testChainLeft", CombinatorTests.testChainLeft),
        ("testChainLeft1", CombinatorTests.testChainLeft1),
        ("testNoOccurence", CombinatorTests.testNoOccurence),
        ("testManyTill", CombinatorTests.testManyTill),
        ("testRecursive", CombinatorTests.testRecursive),
        ("testEof", CombinatorTests.testEof)
    ]),
    testCase([
        ("testIdentifier", GenericTokenParserTests.testIdentifier),
        ("testReservedName", GenericTokenParserTests.testReservedName),
        ("testLegalOperator", GenericTokenParserTests.testLegalOperator),
        ("testReservedOperator", GenericTokenParserTests.testReservedOperator),
        ("testCharacterLiteral", GenericTokenParserTests.testCharacterLiteral),
        ("testStringLiteral", GenericTokenParserTests.testStringLiteral),
        ("testSwiftStringLiteral",
            GenericTokenParserTests.testSwiftStringLiteral),
        ("testJSONStringLiteral",
            GenericTokenParserTests.testJSONStringLiteral),
        ("testNatural", GenericTokenParserTests.testNatural),
        ("testInteger", GenericTokenParserTests.testInteger),
        ("testIntegerAsFloat", GenericTokenParserTests.testIntegerAsFloat),
        ("testFloat", GenericTokenParserTests.testFloat),
        ("testNumber", GenericTokenParserTests.testNumber),
        ("testDecimal", GenericTokenParserTests.testDecimal),
        ("testHexadecimal", GenericTokenParserTests.testHexadecimal),
        ("testOctal", GenericTokenParserTests.testOctal),
        ("testSymbol", GenericTokenParserTests.testSymbol),
        ("testWhiteSpace", GenericTokenParserTests.testWhiteSpace),
        ("testParentheses", GenericTokenParserTests.testParentheses),
        ("testBraces", GenericTokenParserTests.testBraces),
        ("testAngles", GenericTokenParserTests.testAngles),
        ("testBrackets", GenericTokenParserTests.testBrackets),
        ("testPunctuations", GenericTokenParserTests.testPunctuations),
        ("testSemicolonSeparated",
            GenericTokenParserTests.testSemicolonSeparated),
        ("testSemicolonSeparated1",
            GenericTokenParserTests.testSemicolonSeparated1),
        ("testCommaSeparated", GenericTokenParserTests.testCommaSeparated),
        ("testCommaSeparated1", GenericTokenParserTests.testCommaSeparated1)
    ]),
    testCase([
        ("testCharacterError", ErrorMessageTests.testCharacterError),
        ("testStringError", ErrorMessageTests.testStringError),
        ("testEofError", ErrorMessageTests.testEofError),
        ("testChoiceError", ErrorMessageTests.testChoiceError),
        ("testCtrlCharError", ErrorMessageTests.testCtrlCharError),
        ("testPositionError", ErrorMessageTests.testPositionError),
        ("testNoOccurenceError", ErrorMessageTests.testNoOccurenceError),
        ("testLabelError", ErrorMessageTests.testLabelError),
        ("testMultiLabelError", ErrorMessageTests.testMultiLabelError),
        ("testGenericError", ErrorMessageTests.testGenericError),
        ("testUnknownError", ErrorMessageTests.testUnknownError)
    ]),
    testCase([
        ("testExpr", ExpressionTests.testExpr),
        ("testReplaceRange", ExpressionTests.testReplaceRange)
    ]),
    testCase([
        ("testMap", GenericParserTests.testMap),
        ("testApplicative", GenericParserTests.testApplicative),
        ("testAlternative", GenericParserTests.testAlternative),
        ("testFlatMap", GenericParserTests.testFlatMap),
        ("testAtempt", GenericParserTests.testAtempt),
        ("testLookAhead", GenericParserTests.testLookAhead),
        ("testMany", GenericParserTests.testMany),
        ("testSkipMany", GenericParserTests.testSkipMany),
        ("testEmpty", GenericParserTests.testEmpty),
        ("testLabel", GenericParserTests.testLabel),
        ("testLift2", GenericParserTests.testLift2),
        ("testLift3", GenericParserTests.testLift3),
        ("testLift4", GenericParserTests.testLift4),
        ("testLift5", GenericParserTests.testLift5),
        ("testUpdateUserState", GenericParserTests.testUpdateUserState),
        ("testParseArray", GenericParserTests.testParseArray)
    ]),
    testCase([
        ("testJSONStatisticsParserPerformance",
            JSONBenchmarkTests.testJSONStatisticsParserPerformance)
    ]),
    testCase([
        ("testCollectionMethods", PermutationTests.testCollectionMethods),
        ("testPermutation", PermutationTests.testPermutation),
        ("testPermutationWithSeparator",
            PermutationTests.testPermutationWithSeparator),
        ("testPermutationWithOptional",
            PermutationTests.testPermutationWithOptional),
        ("testPermutationWithSeparatorAndOptional",
            PermutationTests.testPermutationWithSeparatorAndOptional),
        ("testPermutationWithNil", PermutationTests.testPermutationWithNil)
    ]),
    testCase([
        ("testComparable", PositionTests.testComparable),
        ("testColumnPosition", PositionTests.testColumnPosition),
        ("testLineColumnPosition", PositionTests.testLineColumnPosition),
        ("testTabPosition", PositionTests.testTabPosition)
    ]),
    testCase([
        ("testLast", StringTests.testLast)
    ]),
    testCase([
        ("testFromInt", UnicodeScalarTests.testFromInt),
        ("testFromUInt32", UnicodeScalarTests.testFromUInt32)
    ])
])
