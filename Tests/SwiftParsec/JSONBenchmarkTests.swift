//
//  BenchmarkTests.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2016-07-16.
//  Copyright © 2016 David Dufresne. All rights reserved.
//

import XCTest
import SwiftParsec

class BenchmarkTests: XCTestCase {

    private typealias JsonStatistics = (
        booleanCount: Int,
        numberCount: Int,
        stringCount: Int,
        arrayCount: Int,
        objectCount: Int,
        nullCount: Int
    )
    
    private typealias StatisticsParser =
        GenericParser<String, JsonStatistics, ()>
    
    // Test the performance of a parser gathering basic statistics on a JSON
    // file. The goal is to keep the building part as light as possible to
    // test the parsing speed without to much influence from the building part.
    func testJsonStatisticsParserPerformance() {
        
        let json = LanguageDefinition<JsonStatistics>.json
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
        
        var jarray: GenericParser<String, JsonStatistics, ()>!
        var jobject: GenericParser<String, JsonStatistics, ()>!
        
        let _ = GenericParser.recursive { (
            jvalue: GenericParser<String, JsonStatistics, ()>
        ) in
            
            let jarrayValues = lexer.commaSeparated(jvalue)
            jarray = lexer.brackets(jarrayValues) *>
            StatisticsParser.updateUserState { statistics in
                    
                var stats = statistics
                stats.arrayCount += 1
                    
                return stats
                    
            }
            
            let nameValue = stringLiteral >>- { name in
                    
                symbol(":") *> jvalue.map { value in (name, ()) }
                    
            }
            
            let dictionary: GenericParser<String, JsonStatistics, [String: ()]> =
            (symbol(",") *> nameValue).manyAccumulator { assoc, dict in
                    
                return dict
                    
            }
            
            let jobjectDict = nameValue >>- { assoc in
                    
                dictionary >>- { dict in
                        
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
        
        let bundle = Bundle(for: self.dynamicType)
        let path = bundle.path(forResource: "SampleJSON", ofType: "json")!
        let jsonData = try! String(
            contentsOfFile: path,
            encoding: String.Encoding.utf8
        );
        
        var statistics: JsonStatistics?
        
        self.measure {
            do {
                
                let (_, state) = try jsonParser.run(
                    userState: initialState,
                    sourceName: "",
                    input: jsonData
                )
                
                statistics = state
                
            } catch let error {
                
                XCTFail(String(error))
                
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
