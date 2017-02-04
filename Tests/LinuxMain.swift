import XCTest
@testable import SwiftParsecTests

XCTMain([
    testCase(CharacterTests.allTests),
    testCase(CharacterSetTests.allTests),
    testCase(CombinatorTests.allTests),
    testCase(ErrorMessageTests.allTests),
    testCase(ExpressionTests.allTests),
    testCase(GenericParserTests.allTests),
    testCase(GenericTokenParserTests.allTests),
    testCase(JSONBenchmarkTests.allTests),
    testCase(PermutationTests.allTests),
    testCase(PositionTests.allTests),
    testCase(StringTests.allTests),
    testCase(UnicodeScalarTests.allTests)
])
