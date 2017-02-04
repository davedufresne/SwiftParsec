import XCTest
@testable import SwiftParsecTests

XCTMain([
    testCase(CharacterParsersTests.allTests),
    testCase(CharacterSetTests.allTests),
    testCase(CombinatorParsersTests.allTests),
    testCase(ErrorMessageTests.allTests),
    testCase(ExpressionParserTests.allTests),
    testCase(GenericParserTests.allTests),
    testCase(GenericTokenParserTests.allTests),
    testCase(JSONBenchmarkTests.allTests),
    testCase(PermutationTests.allTests),
    testCase(PositionTests.allTests),
    testCase(StringTests.allTests),
    testCase(UnicodeScalarTests.allTests)
])
