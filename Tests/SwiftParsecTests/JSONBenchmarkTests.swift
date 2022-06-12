// ==============================================================================
// BenchmarkTests.swift
// SwiftParsec
//
// Created by David Dufresne on 2016-07-16.
// Copyright © 2016 David Dufresne. All rights reserved.
// ==============================================================================
// swiftlint:disable force_try

import XCTest
import SwiftParsec
import class Foundation.Bundle

class JSONBenchmarkTests: XCTestCase {
    private typealias JSONStatistics = (
        booleanCount: Int,
        numberCount: Int,
        stringCount: Int,
        arrayCount: Int,
        objectCount: Int,
        nullCount: Int
    )

    private typealias StatisticsParser =
        GenericParser<String, JSONStatistics, ()>

    // Test the performance of a parser gathering basic statistics on a JSON
    // file. The goal is to keep the building part as light as possible to
    // test the parsing speed without too much influence from the building part.
    func testJSONStatisticsParserPerformance() {
        let json = LanguageDefinition<JSONStatistics>.json
        let lexer = GenericTokenParser(languageDefinition: json)
        let symbol = lexer.symbol

        let jbool = (symbol("true") <|> symbol("false")) *>
        StatisticsParser.updateUserState { statistics in
            var stats = statistics
            stats.booleanCount += 1

            return stats
        }

        let stringLiteral = lexer.stringLiteral

        let jstring = stringLiteral *>
        StatisticsParser.updateUserState { statistics in
            var stats = statistics
            stats.stringCount += 1

            return stats
        }

        let jnumber = (lexer.float.attempt <|> lexer.integerAsFloat) *>
        StatisticsParser.updateUserState { statistics in
            var stats = statistics
            stats.numberCount += 1

            return stats
        }

        let jnull = symbol("null") *>
        StatisticsParser.updateUserState { statistics in
            var stats = statistics
            stats.nullCount += 1

            return stats
        }

        var jarray: GenericParser<String, JSONStatistics, ()>!
        var jobject: GenericParser<String, JSONStatistics, ()>!

        _ = GenericParser.recursive { (
            jvalue: GenericParser<String, JSONStatistics, ()>
        ) in

            let jarrayValues = lexer.commaSeparated(jvalue)
            jarray = lexer.brackets(jarrayValues) *>
            StatisticsParser.updateUserState { statistics in
                var stats = statistics
                stats.arrayCount += 1

                return stats
            }

            let nameValue = stringLiteral >>- { name in
                symbol(":") *> jvalue.map { _ in (name, ()) }
            }

            let dictionary: GenericParser<String, JSONStatistics, [String: ()]> =
            (symbol(",") *> nameValue).manyAccumulator { _, dict in
                return dict
            }

            let jobjectDict = nameValue >>- { _ in
                dictionary >>- { _ in
                    return GenericParser(result: ())
                }
            }

            let jobjectValues = jobjectDict <|> GenericParser(result: ())
            jobject = lexer.braces(jobjectValues) *>
            StatisticsParser.updateUserState { statistics in
                var stats = statistics
                stats.objectCount += 1

                return stats
            }

            return jstring <|> jnumber <|> jbool <|> jnull <|> jarray <|>
                jobject
        }

        let jsonParser = lexer.whiteSpace *> (jobject <|> jarray)

        let initialState = (
            booleanCount: 0,
            numberCount: 0,
            stringCount: 0,
            arrayCount: 0,
            objectCount: 0,
            nullCount: 0
        )

        #if SWIFT_PACKAGE

        let bundle = Bundle(path: "Tests/SwiftParsecTests")!

        #else

        let bundle = Bundle(for: type(of: self))

        #endif

        let path = bundle.path(forResource: "SampleJSON", ofType: "json")!

        let jsonData = try! String(
            contentsOfFile: path,
            encoding: String.Encoding.utf8
        )

        var statistics: JSONStatistics?

        let statisticsParser = jsonParser *>
            GenericParser<String, JSONStatistics, JSONStatistics>.userState
        self.measure {
            do {
                let stats = try statisticsParser.run(
                    userState: initialState,
                    sourceName: "",
                    input: jsonData
                )

                statistics = stats
            } catch let error {
                XCTFail(String(describing: error))
            }
        }

        if let stats = statistics {
            XCTAssertEqual(3, stats.booleanCount)
            XCTAssertEqual(1503, stats.numberCount)
            XCTAssertEqual(3015, stats.stringCount)
            XCTAssertEqual(999, stats.arrayCount)
            XCTAssertEqual(1015, stats.objectCount)
            XCTAssertEqual(2, stats.nullCount)
        }
    }
}

extension JSONBenchmarkTests {
    static var allTests: [(String, (JSONBenchmarkTests) -> () throws -> Void)] {
        return [
            ("testJSONStatisticsParserPerformance",
             testJSONStatisticsParserPerformance)
        ]
    }
}
